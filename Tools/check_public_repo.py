#!/usr/bin/env python3
"""Check tracked working files, and optionally reachable Git history, without printing secrets.
This intentionally checks high-confidence patterns; it is not a complete security audit.
"""
import argparse
import re
import subprocess
from pathlib import Path


def git(*args):
    return subprocess.check_output(['git', *args])


PATTERNS = {
    'private key': rb'-----BEGIN (?:RSA |EC |OPENSSH |DSA |ENCRYPTED )?PRIVATE KEY-----',
    'AWS access key': rb'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b',
    'GitHub token': rb'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b',
    'Slack token': rb'\bxox[baprs]-[A-Za-z0-9-]{20,}\b',
    'Stripe secret': rb'\bsk_live_[A-Za-z0-9]{20,}\b',
    'Google API key': rb'\bAIza[A-Za-z0-9_-]{35}\b',
    'credential in URL': rb'https?://[^\s/:@"\\<>]+:[^\s/@"\\<>]{8,}@',
}
SENSITIVE_SUFFIXES = {'.p8', '.p12', '.pfx', '.mobileprovision', '.provisionprofile', '.keychain', '.keychain-db'}


def inspect(path, data, label):
    findings = []
    name = Path(path).name
    if Path(path).suffix in SENSITIVE_SUFFIXES or name == '.env' or (name.startswith('.env.') and name not in {'.env.default', '.env.example'}):
        findings.append(f'{label}: {path}: credential/configuration file must remain private')
    for kind, pattern in PATTERNS.items():
        if re.search(pattern, data):
            findings.append(f'{label}: {path}: possible {kind} (value redacted)')
    return findings


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--history', action='store_true', help='also scan every blob reachable from local refs')
    args = parser.parse_args()
    root = Path(git('rev-parse', '--show-toplevel').decode().strip())
    findings = []
    count = 0
    for raw in git('ls-files', '-z').split(b'\0'):
        if not raw:
            continue
        path = raw.decode('utf-8', errors='surrogateescape')
        file = root / path
        if file.is_file():
            findings.extend(inspect(path, file.read_bytes(), 'working tree'))
            count += 1
    if args.history:
        # Reuse one Git process for all objects.
        with subprocess.Popen(['git', 'cat-file', '--batch'], stdin=subprocess.PIPE, stdout=subprocess.PIPE) as batch:
            for line in git('rev-list', '--objects', '--all').splitlines():
                fields = line.split(b' ', 1)
                if len(fields) != 2:
                    continue
                oid, raw = fields
                batch.stdin.write(oid + b'\n')
                batch.stdin.flush()
                header = batch.stdout.readline().split()
                if len(header) != 3:
                    raise RuntimeError('Unexpected git cat-file response')
                data = batch.stdout.read(int(header[2]))
                batch.stdout.read(1)
                if header[1] != b'blob':
                    continue
                path = raw.decode('utf-8', errors='surrogateescape')
                findings.extend(inspect(path, data, 'history '+oid.decode()[:12]))
                count += 1
            batch.stdin.close()
            if batch.wait():
                raise RuntimeError('git cat-file failed')
    for finding in findings:
        print(finding)
    print(f'Checked {count} files/blobs; {len(findings)} findings. Pattern checks cannot prove absence of secrets.')
    return bool(findings)


if __name__ == '__main__':
    raise SystemExit(main())

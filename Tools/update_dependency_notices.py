#!/usr/bin/env python3
"""Refresh bundled dependency notices after pod install and SwiftPM resolution."""
import argparse
import html
import plistlib
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--swift-checkouts', type=Path, required=True, help='Xcode DerivedData/SourcePackages/checkouts')
args = parser.parse_args()
root = Path(__file__).resolve().parent.parent
notices = {}
plists = sorted((root / 'Pods/Target Support Files').glob('*/*-acknowledgements.plist'))
if not plists or not args.swift_checkouts.is_dir():
    parser.error('Install Pods and resolve Swift packages before refreshing notices')
for file in plists:
    for item in plistlib.loads(file.read_bytes()).get('PreferenceSpecifiers', []):
        title, text = item.get('Title'), item.get('FooterText')
        if title and text and title != 'Acknowledgements':
            notices[('CocoaPods: '+title, text)] = None
missing = []
for checkout in sorted(args.swift_checkouts.iterdir()):
    if not checkout.is_dir():
        continue
    files = [p for p in sorted(checkout.iterdir()) if p.is_file() and p.name.lower().startswith(('license', 'licence', 'copying', 'notice', 'copyright'))]
    if not files and checkout.name == 'maplibre-gl-native-distribution':
        manifest = (checkout / 'Package.swift').read_text()
        if ('ios-v5.12.2/Mapbox-5.12.2.zip' in manifest and
                '348453495bad198b380e033a6bc6e6134bf71be27116904a25152b93a2d77491' in manifest):
            files = [root / 'third_party/maplibre-5.12.2/LICENSE.md']
    if not files:
        missing.append(checkout.name)
    for file in files:
        notices[('SwiftPM: '+checkout.name+' / '+file.name, file.read_text())] = None
start, end = '<!-- BEGIN RESOLVED DEPENDENCY NOTICES -->', '<!-- END RESOLVED DEPENDENCY NOTICES -->'
section = start+'\n<h2>Resolved dependency notices</h2>\n<p>Generated from installed CocoaPods acknowledgements and Swift package license files. Re-run Tools/update_dependency_notices.py when dependencies change. Original upstream notices follow.</p>\n'
for title, text in sorted(notices):
    section += '<details><summary>'+html.escape(title)+'</summary><pre>'+html.escape('\n'.join(line.rstrip() for line in text.splitlines()))+'</pre></details>\n'
section += end
output = root / 'Riot/Assets/third_party_licenses.html'
s = output.read_text()
if start in s:
    first, rest = s.split(start, 1)
    _, last = rest.split(end, 1)
    s = first+section+last
else:
    s = s.replace('</body>', section+'\n</body>')
output.write_text(s)
print(f'Bundled {len(notices)} resolved dependency notices')
if missing:
    parser.exit(1, 'Release review required: no root license file in '+', '.join(missing)+'; obtain the exact binary distribution notices before shipping.\n')

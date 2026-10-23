# Security and public repository preparation

Do not post access tokens, passwords, recovery keys, decrypted messages, device logs or signing material in public issues. Report security problems privately to the repository maintainer through an enabled GitHub private vulnerability reporting channel; if unavailable, request a private reporting channel without disclosing exploit details.

## Local configuration

Keep Apple signing certificates, provisioning profiles, App Store Connect keys, account passwords and automation tokens outside Git. Config/LocalSigning.xcconfig (and the Alpha variant equivalent) can override DEVELOPMENT_TEAM and provisioning settings locally and is ignored. Set Fastlane signing/account variables through the local environment or repository secrets; the tracked .env.default files contain public defaults only. An Apple team ID or service URL is not itself an authentication secret.

Analytics and Sentry startup are disabled at build time. Manual, shake-triggered and automatic diagnostic uploads are disabled centrally, including for previously saved opt-in settings. Re-enabling reporting requires an owned endpoint and accurate disclosures. The in-app privacy link points to PRIVACY.md; help points to this fork's issue tracker. No upstream acceptable-use policy is presented as TeleIraq's policy. Service operators must supply their own accurate server-side policies before production distribution.

## Publication and release checks

- Run `python3 Tools/check_public_repo.py --history` before publishing and after changes. It scans tracked working files and blobs reachable from local refs for selected credential patterns without displaying values. It is a limited check, not a security certification. Review newly added/untracked files and use an independent secret scanner too.
- If a credential is found in any commit, revoke/rotate it first. Removing it from the current file or adding it to .gitignore does not remove history. Coordinate any history cleanup separately; do not rewrite collaborators' history blindly. Unavailable remote refs and GitHub caches are outside the local scan.
- Enable GitHub secret scanning/push protection where available. Keep workflow permissions minimal. Privileged upstream triage jobs are restricted to the upstream repository; signing releases require manual dispatch on a trusted ref. Do not dispatch a signing build from untrusted code.
- Publish exact corresponding source and preserve LICENSE, NOTICE.md, AUTHORS.rst, upstream headers, and dependency notices. Refresh bundled dependency notices with `python3 Tools/update_dependency_notices.py --swift-checkouts /path/to/DerivedData/SourcePackages/checkouts` after installing Pods and resolving Swift packages. MapLibre 5.12.2 notices are vendored from its exact source release under third_party/maplibre-5.12.2; the generator verifies the binary version and checksum before using that fallback. Review bundled framework notices again when dependencies change.
- The main app and launch icons use existing TeleIraq artwork; inherited horizontal and legacy logos now reuse that artwork. Preserve upstream attribution and verify branding and source/privacy links in store metadata and each release.
- Perform a device/simulator build and test authentication, encrypted messaging, key backup, notifications and extension entitlements. Review dependency advisories and transport settings: the inherited Info.plist permits arbitrary loads for Matrix interoperability; a public-source check does not establish runtime security.

The repository preparation changes do not publish the repository, rotate credentials, rewrite Git history, or certify legal compliance or application security.

# TeleIraq client privacy notice

Updated 2026-10-23. This notice describes the TeleIraq iOS client in this repository. TeleIraq is an independent Matrix client and is not operated or endorsed by Element.

## Accounts and communications

The client connects to your selected Matrix homeserver; the default is https://im.teleiraq.com. Signing in, syncing rooms and account data, sending messages, uploading attachments and managing devices exchange data with that server. Room membership, account identifiers, timestamps and other protocol metadata may be visible to server operators. Encryption depends on each room's settings and does not hide all metadata. Messages in unencrypted rooms and files shared there are readable by the servers involved. Federation may send room data to other participating servers.

Credentials, encryption keys, account settings and cached messages are stored on your device using the app's storage and keychain. Protect your device, recovery information and exported files. Signing out or clearing local data does not necessarily delete data retained by a server or other participants. Account deactivation is available through Settings when supported by your homeserver.

## Optional features and external services

- Notifications use Apple's push infrastructure and the configured push gateway (default https://push.teleiraq.com). Your notification settings determine whether message content is included in notifications.
- Calls exchange connection and media data with participants and configured call/relay services. The default conference service is https://jitsi.teleiraq.com. Network addresses may be disclosed in calls depending on your settings and infrastructure.
- Camera, microphone, photos, contacts and location are accessed through permissions and the features you choose. Sharing contacts with an identity server or sharing your location transmits that data to the selected services or conversation. The default identity server is https://vector.im.
- Maps, link previews, integrations, widgets and external links can contact third-party services, which receive ordinary network metadata and feature-specific requests. Review the services you enable; their own policies apply.

## Diagnostics

This build disables analytics collection and Sentry startup. Manual crash/log uploads, shake-to-report and automatic decryption-issue uploads are disabled by a build-time gate, including for previously saved opt-in settings. The app may retain local diagnostic logs for troubleshooting. Do not publish logs without reviewing them for personal information.

## Server policies and questions

This notice does not claim server retention periods, server locations, legal bases or deletion guarantees: those are controlled by the operators of your chosen services. Obtain their policies before using those services for sensitive information. Repository questions can be raised at https://github.com/moahmmadjaber/teleiraq-main/issues without including passwords, recovery keys or private messages. For vulnerabilities or private data concerns, follow SECURITY.md and request a private channel before sharing details.

Any distributor or service operator must provide its own accurate operator identity, contact information and applicable server-side privacy disclosures before a production release. This client notice is not a substitute for those disclosures.

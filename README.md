# TeleIraq iOS

TeleIraq is an independent fork of [Element Classic iOS](https://github.com/element-hq/element-ios), a Matrix client. It is not an official Element application or endorsed by Element.

This fork uses the free AGPL-3.0 license option. See [LICENSE](LICENSE), [NOTICE.md](NOTICE.md) and [SECURITY.md](SECURITY.md) for attribution, source-distribution requirements and remaining release checks. Existing file and dependency licenses remain applicable.

## Build

Follow [INSTALL.md](INSTALL.md) for the required Xcode, Ruby, CocoaPods and XcodeGen setup. The Matrix SDK source is included in this checkout. Keep Podfile.lock and the SwiftPM Package.resolved file for reproducible dependency resolution.

```sh
bundle install
xcodegen
bundle exec pod install
open Riot.xcworkspace
```

Use your own Apple developer account and signing configuration for device builds. Put local signing overrides in the ignored `Config/LocalSigning.xcconfig`; configure Alpha overrides in `Variants/Alpha/Config/LocalSigning.xcconfig`. Public server URLs and bundle identifiers are configuration, not credentials. Fastlane signing/account values must be supplied privately.

Before publication run:

```sh
python3 Tools/check_public_repo.py --history
```

For every binary release, publish the complete corresponding source at the exact release revision with its build scripts and dependency lockfiles. Update the source link in the bundled third-party notices if the repository moves. See SECURITY.md for remaining distribution checks, including branding, policies and dependency notices.

## Upstream copyright and licensing notice

The following is the original upstream notice. TeleIraq elects the AGPL option; a paid license is not granted by this repository.

## Copyright & License

Copyright (c) 2014-2017 OpenMarket Ltd.
Copyright (c) 2017 Vector Creations Ltd.
Copyright (c) 2017-2025 New Vector Ltd.
Copyright (c) 2025 Element Creations Ltd.

This software is dual licensed by New Vector Ltd (Element). It can be used either:

(1) for free under the terms of the GNU Affero General Public License (as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version); OR

(2) under the terms of a paid-for Element Commercial License agreement between you and Element (the terms of which may vary depending on what you and Element have agreed to).

Unless required by applicable law or agreed to in writing, software distributed under the Licenses is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the Licenses for the specific language governing permissions and limitations under the Licenses.

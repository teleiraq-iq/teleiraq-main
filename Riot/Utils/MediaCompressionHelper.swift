//
// Copyright 2021-2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// A collection of helpful functions for media compression.
class MediaCompressionHelper: NSObject {
    /// Always prompt the user to confirm the size when sending images and videos.
    @objc static var defaultCompressionMode: MXKRoomInputToolbarCompressionMode {
        return MXKRoomInputToolbarCompressionModePrompt
    }
}

extension BuildSettings.MediaCompressionMode {
    /// The compression mode as an `MXKRoomInputToolbarCompressionMode` value.
    var mxkCompressionMode: MXKRoomInputToolbarCompressionMode {
        switch self {
        case .prompt:
            return MXKRoomInputToolbarCompressionModePrompt
        case .small:
            return MXKRoomInputToolbarCompressionModeSmall
        case .medium:
            return MXKRoomInputToolbarCompressionModeMedium
        case .large:
            return MXKRoomInputToolbarCompressionModeLarge
        case .none:
            return MXKRoomInputToolbarCompressionModeNone
        }
    }
}

//
//  AppDisplayData.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import Foundation
import SwiftUI

/// View model for displaying app with icon and metadata
struct AppDisplayData: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleId: String
    let platforms: [Platform]
    let versions: [AppVersion]
    let primaryLocale: String?
    var iconImage: Image?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AppDisplayData, rhs: AppDisplayData) -> Bool {
        lhs.id == rhs.id
    }
}

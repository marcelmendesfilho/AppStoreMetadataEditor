//
//  AppIconData.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import Foundation

struct AppIconData: Codable {
    let id: String
    let type: String
    let attributes: IconAttributes?
}

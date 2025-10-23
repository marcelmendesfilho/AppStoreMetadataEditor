//
//  AppVersionLocalization.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

struct AppVersionLocalization: Identifiable, Codable {
    let id: String
    let type: String
    let attributes: LocalizationAttributes
}

struct LocalizationAttributes: Codable {
    let locale: String
    let description: String?
    let keywords: String?
    let whatsNew: String?
    let promotionalText: String?
    let supportUrl: String?
    let marketingUrl: String?
}

// Attributes para UPDATE (sem locale, que é imutável)
struct LocalizationUpdateAttributes: Codable {
    let description: String?
    let keywords: String?
    let whatsNew: String?
    let promotionalText: String?
    let supportUrl: String?
    let marketingUrl: String?
}

struct AppVersionLocalizationResponse: Codable {
    let data: [AppVersionLocalization]
    let links: Links?

    struct Links: Codable {
        let `self`: String?
        let next: String?
    }
}

// Update request
struct AppVersionLocalizationUpdateRequest: Codable {
    let data: DataContainer

    struct DataContainer: Codable {
        let type: String
        let id: String
        let attributes: LocalizationUpdateAttributes
    }
}

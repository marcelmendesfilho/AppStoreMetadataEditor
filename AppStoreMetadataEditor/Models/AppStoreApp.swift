//
//  AppStoreApp.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

struct AppStoreApp: Identifiable, Codable {
    let id: String
    let attributes: AppAttributes
    let relationships: AppRelationships?

    struct AppAttributes: Codable {
        let name: String
        let bundleId: String
        let sku: String
        let primaryLocale: String?
    }

    struct AppRelationships: Codable {
        let appStoreVersions: RelationshipData?
    }

    struct RelationshipData: Codable {
        let data: [RelationshipItem]?
    }

    struct RelationshipItem: Codable {
        let id: String
        let type: String
    }
}

// Response wrapper for API
struct AppsResponse: Codable {
    let data: [AppStoreApp]
    let included: [IncludedItem]?
    let links: Links?

    struct Links: Codable {
        let `self`: String?
        let next: String?
    }
}

struct IncludedItem: Codable {
    let id: String
    let type: String
    let attributes: VersionAttributes?
}

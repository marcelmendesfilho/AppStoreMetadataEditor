//
//  AppVersion.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

struct AppVersion: Identifiable, Codable, Hashable {
    let id: String
    let attributes: VersionAttributes
    let relationships: VersionRelationships?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.id == rhs.id
    }
}

struct VersionAttributes: Codable, Hashable {
    let versionString: String?
    let platform: Platform?
    let appStoreState: AppStoreState?
    let copyright: String?
    let releaseType: String?
    let earliestReleaseDate: Date?
    let downloadable: Bool?
    let createdDate: Date?
}

enum Platform: String, Codable {
    case iOS = "IOS"
    case macOS = "MAC_OS"
    case tvOS = "TV_OS"
    case visionOS = "VISION_OS"
    
    var displayName: String {
        switch self {
        case .iOS: return "iOS"
        case .macOS: return "macOS"
        case .tvOS: return "tvOS"
        case .visionOS: return "visionOS"
        }
    }
}

enum AppStoreState: String, Codable {
    case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
    case waitingForReview = "WAITING_FOR_REVIEW"
    case inReview = "IN_REVIEW"
    case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
    case readyForSale = "READY_FOR_SALE"
    case rejected = "REJECTED"
    case metadataRejected = "METADATA_REJECTED"
    case removedFromSale = "REMOVED_FROM_SALE"
    case developerRemovedFromSale = "DEVELOPER_REMOVED_FROM_SALE"
    case pendingAppleRelease = "PENDING_APPLE_RELEASE"
    case processingForAppStore = "PROCESSING_FOR_APP_STORE"
    case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
    case invalidBinary = "INVALID_BINARY"

    var isEditable: Bool {
        return self == .prepareForSubmission
    }
}

struct VersionRelationships: Codable, Hashable {
    let appStoreVersionLocalizations: RelationshipData?

    struct RelationshipData: Codable, Hashable {
        let data: [RelationshipItem]?
    }

    struct RelationshipItem: Codable, Hashable {
        let id: String
        let type: String
    }
}

struct AppVersionsResponse: Codable {
    let data: [AppVersion]
    let included: [AppVersionLocalization]?
    let links: Links?

    struct Links: Codable {
        let `self`: String?
        let next: String?
    }
}

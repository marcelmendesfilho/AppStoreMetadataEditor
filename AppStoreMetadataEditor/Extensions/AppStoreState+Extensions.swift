//
//  AppStoreState+Extensions.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import SwiftUI

extension AppStoreState {
    var displayName: String {
        switch self {
        case .prepareForSubmission: return LocalizedStrings.statePrepareForSubmission
        case .waitingForReview: return LocalizedStrings.stateWaitingForReview
        case .inReview: return LocalizedStrings.stateInReview
        case .pendingDeveloperRelease: return LocalizedStrings.statePendingDeveloperRelease
        case .readyForSale: return LocalizedStrings.stateReadyForSale
        case .rejected: return LocalizedStrings.stateRejected
        case .metadataRejected: return LocalizedStrings.stateMetadataRejected
        case .removedFromSale: return LocalizedStrings.stateRemovedFromSale
        case .developerRemovedFromSale: return LocalizedStrings.stateDeveloperRemovedFromSale
        case .pendingAppleRelease: return LocalizedStrings.statePendingAppleRelease
        case .processingForAppStore: return LocalizedStrings.stateProcessingForAppStore
        case .replacedWithNewVersion: return LocalizedStrings.stateReplacedWithNewVersion
        case .invalidBinary: return LocalizedStrings.stateInvalidBinary
        }
    }

    var color: Color {
        switch self {
        case .prepareForSubmission: return .blue
        case .waitingForReview: return .orange
        case .inReview: return .purple
        case .readyForSale: return .green
        case .rejected: return .red
        default: return .gray
        }
    }
}

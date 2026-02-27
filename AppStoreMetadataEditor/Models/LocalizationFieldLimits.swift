//
//  LocalizationFieldLimits.swift
//  AppStoreMetadataEditor
//
//  Created by Codex on 27/02/26.
//

import Foundation

enum LocalizationFieldKey: String, CaseIterable {
    case promotionalText
    case description
    case whatsNew
    case keywords

    var maxLength: Int {
        switch self {
        case .promotionalText: return 170
        case .description: return 4000
        case .whatsNew: return 4000
        case .keywords: return 100
        }
    }
}

enum LocalizationFieldLimits {
    static let byField: [String: Int] = Dictionary(
        uniqueKeysWithValues: LocalizationFieldKey.allCases.map { ($0.rawValue, $0.maxLength) }
    )

    static func maxLength(for field: String) -> Int? {
        byField[field]
    }
}

//
//  TranslationServiceProtocol.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

protocol TranslationServiceProtocol {
    func translate(
        text: String,
        from sourceLocale: String,
        to targetLocales: [String]
    ) async throws -> [String: String]

    func translateFields(
        fields: [String: String],
        fieldCharacterLimits: [String: Int],
        from sourceLocale: String,
        to targetLocale: String
    ) async throws -> [String: String]
}

struct TranslationRequest {
    let promotionalText: String?
    let description: String?
    let whatsNew: String?
    let keywords: String?
    let targetLocales: [String]
}

struct TranslationResponse {
    let locale: String
    let promotionalText: String?
    let description: String?
    let whatsNew: String?
    let keywords: String?
}

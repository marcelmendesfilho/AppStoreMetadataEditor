//
//  MockTranslationService.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import Foundation

class MockTranslationService: TranslationServiceProtocol {
    private let mockPayload: [String: String] = [
        "promotionalText": "Promotional test",
        "description": "Test description",
        "whatsNew": "Test what's new",
        "keywords": "test keywords"
    ]

    init() {}

    func translate(text: String, from sourceLocale: String, to targetLocales: [String]) async throws -> [String: String] {
        // Simular um pequeno delay para parecer realista
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos

        var result: [String: String] = [:]
        for locale in targetLocales {
            result[locale] = "Mock translation from \(sourceLocale) to \(locale): \(text)"
        }
        return result
    }

    func translateFields(fields: [String: String], from sourceLocale: String, to targetLocale: String) async throws -> [String: String] {
        // Simular um pequeno delay para parecer realista
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos

        var result: [String: String] = [:]

        // Para cada campo solicitado, retornar o valor do mock se existir
        for (key, _) in fields {
            if let mockValue = mockPayload[key] {
                result[key] = mockValue
            } else {
                // Se não houver mock para este campo, retornar uma mensagem genérica
                result[key] = "Mock translation of \(key) from \(sourceLocale) to \(targetLocale)"
            }
        }

        print("🔧 [MockTranslationService] Returning mock translations for \(result.keys.joined(separator: ", "))")

        return result
    }
}

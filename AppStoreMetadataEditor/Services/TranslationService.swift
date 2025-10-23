//
//  TranslationService.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

class TranslationService: TranslationServiceProtocol {
    private let configuration: ConfigurationProtocol

    private var apiKey: String {
        configuration.openRouterAPIKey
    }

    private var baseURL: String {
        configuration.openRouterBaseURL
    }

    private var model: String {
        configuration.openRouterModel
    }

    init(configuration: ConfigurationProtocol) {
        self.configuration = configuration
    }

    func translate(text: String, from sourceLocale: String, to targetLocales: [String]) async throws -> [String: String] {
        let prompt = """
        Translate the following text from \(sourceLocale) to these languages: \(targetLocales.joined(separator: ", ")).
        Return a JSON object where keys are locale codes and values are translations.

        Text to translate:
        \(text)

        Return only the JSON object, no additional text.
        """

        let request = OpenRouterRequest(
            model: model,
            messages: [.init(role: "user", content: prompt)]
        )

        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        // Log da requisição
        print("🌐 [OpenRouter] REQUEST")
        print("URL: \(baseURL)")
        print("Model: \(model)")
        print("Source: \(sourceLocale) → Targets: \(targetLocales.joined(separator: ", "))")
        print("Text length: \(text.count) characters")
        if let bodyString = String(data: urlRequest.httpBody ?? Data(), encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [OpenRouter] Invalid response type")
            throw NetworkError.serverError(-1)
        }

        // Log da resposta
        print("📥 [OpenRouter] RESPONSE")
        print("Status Code: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Body: \(responseString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ [OpenRouter] Server error: \(httpResponse.statusCode)")
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            print("❌ [OpenRouter] No content in response")
            throw NetworkError.decodingError
        }

        print("✅ [OpenRouter] Content received: \(content)")

        // Extrair JSON do conteúdo (pode vir com markdown)
        let jsonString: String
        if content.contains("```json") {
            // Remover markdown code block
            let components = content.components(separatedBy: "```json")
            if components.count > 1 {
                let afterFirst = components[1]
                jsonString = afterFirst.components(separatedBy: "```").first ?? content
            } else {
                jsonString = content
            }
        } else if content.contains("```") {
            // Remover markdown code block sem json
            let components = content.components(separatedBy: "```")
            jsonString = components.count > 1 ? components[1] : content
        } else {
            jsonString = content
        }

        // Parse JSON from response
        guard let jsonData = jsonString.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8),
              let translations = try? JSONDecoder().decode([String: String].self, from: jsonData) else {
            print("❌ [OpenRouter] Failed to parse translations from content")
            print("❌ [OpenRouter] Attempted to parse: \(jsonString)")
            throw NetworkError.decodingError
        }

        print("✅ [OpenRouter] Translations parsed successfully: \(translations.keys.joined(separator: ", "))")

        return translations
    }

    func translateFields(fields: [String: String], from sourceLocale: String, to targetLocale: String) async throws -> [String: String] {
        // Criar um prompt que traduz múltiplos campos de uma vez
        var fieldsText = ""
        for (key, value) in fields {
            fieldsText += "[\(key)]: \(value)\n\n"
        }

        let prompt = """
        Translate the following fields from \(sourceLocale) to \(targetLocale).
        Return a JSON object where keys are the field names and values are the translations.

        Fields to translate:
        \(fieldsText)

        Return only the JSON object with the same keys, no additional text.
        """

        let request = OpenRouterRequest(
            model: model,
            messages: [.init(role: "user", content: prompt)]
        )

        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        // Log da requisição
        print("🌐 [OpenRouter] REQUEST (Multiple Fields)")
        print("URL: \(baseURL)")
        print("Model: \(model)")
        print("Source: \(sourceLocale) → Target: \(targetLocale)")
        print("Fields: \(fields.keys.joined(separator: ", "))")
        if let bodyString = String(data: urlRequest.httpBody ?? Data(), encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [OpenRouter] Invalid response type")
            throw NetworkError.serverError(-1)
        }

        // Log da resposta
        print("📥 [OpenRouter] RESPONSE")
        print("Status Code: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Body: \(responseString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ [OpenRouter] Server error: \(httpResponse.statusCode)")
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            print("❌ [OpenRouter] No content in response")
            throw NetworkError.decodingError
        }

        print("✅ [OpenRouter] Content received: \(content)")

        // Extrair JSON do conteúdo (pode vir com markdown)
        let jsonString: String
        if content.contains("```json") {
            let components = content.components(separatedBy: "```json")
            if components.count > 1 {
                let afterFirst = components[1]
                jsonString = afterFirst.components(separatedBy: "```").first ?? content
            } else {
                jsonString = content
            }
        } else if content.contains("```") {
            let components = content.components(separatedBy: "```")
            jsonString = components.count > 1 ? components[1] : content
        } else {
            jsonString = content
        }

        // Parse JSON from response
        guard let jsonData = jsonString.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8),
              let translations = try? JSONDecoder().decode([String: String].self, from: jsonData) else {
            print("❌ [OpenRouter] Failed to parse translations from content")
            print("❌ [OpenRouter] Attempted to parse: \(jsonString)")
            throw NetworkError.decodingError
        }

        print("✅ [OpenRouter] Translations parsed successfully: \(translations.keys.joined(separator: ", "))")

        return translations
    }
}

struct OpenRouterRequest: Codable {
    let model: String
    let messages: [Message]

    struct Message: Codable {
        let role: String
        let content: String
    }
}

struct OpenRouterResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}

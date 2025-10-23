//
//  Configuration.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

class Configuration: ConfigurationProtocol {
    private let defaults = UserDefaults.standard

    // Keys para UserDefaults
    private let openRouterAPIKeyKey = "openRouterAPIKey"
    private let openRouterBaseURLKey = "openRouterBaseURL"
    private let openRouterModelKey = "openRouterModel"
    private let useMockTranslationKey = "useMockTranslation"

    // Valores padrão
    private let defaultBaseURL = "https://openrouter.ai/api/v1/chat/completions"
    private let defaultModel = "openai/gpt-4o"

    var openRouterAPIKey: String {
        get {
            defaults.string(forKey: openRouterAPIKeyKey) ?? ""
        }
        set {
            defaults.set(newValue, forKey: openRouterAPIKeyKey)
        }
    }

    var openRouterBaseURL: String {
        get {
            defaults.string(forKey: openRouterBaseURLKey) ?? defaultBaseURL
        }
        set {
            defaults.set(newValue, forKey: openRouterBaseURLKey)
        }
    }

    var openRouterModel: String {
        get {
            defaults.string(forKey: openRouterModelKey) ?? defaultModel
        }
        set {
            defaults.set(newValue, forKey: openRouterModelKey)
        }
    }

    var useMockTranslation: Bool {
        get {
            defaults.bool(forKey: useMockTranslationKey)
        }
        set {
            defaults.set(newValue, forKey: useMockTranslationKey)
        }
    }

    init() {}
}

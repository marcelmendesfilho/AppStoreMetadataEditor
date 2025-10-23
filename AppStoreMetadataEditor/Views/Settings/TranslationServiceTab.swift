//
//  TranslationServiceTab.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import SwiftUI

struct TranslationServiceTab: View {
    @Environment(\.dismiss) var dismiss

    private let configuration: ConfigurationProtocol

    @State private var apiKey: String
    @State private var baseURL: String
    @State private var model: String
    @State private var useMock: Bool
    @State private var showSaveConfirmation = false

    init(configuration: ConfigurationProtocol) {
        self.configuration = configuration
        _apiKey = State(initialValue: configuration.openRouterAPIKey)
        _baseURL = State(initialValue: configuration.openRouterBaseURL)
        _model = State(initialValue: configuration.openRouterModel)
        _useMock = State(initialValue: configuration.useMockTranslation)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStrings.translationServiceTitle)
                .font(.title2)
                .bold()

            Form {
                Section(LocalizedStrings.operationMode) {
                    Toggle(LocalizedStrings.useMock, isOn: $useMock)
                        .help(LocalizedStrings.useMockHelp)
                }

                Section(LocalizedStrings.apiConfiguration) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStrings.apiKey)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $apiKey)
                            .frame(height: 60)
                            .font(.system(.body, design: .monospaced))
                            .border(Color.gray.opacity(0.3))
                            .help(LocalizedStrings.apiKeyHelp)
                    }
                    .disabled(useMock)
                    .opacity(useMock ? 0.5 : 1.0)

                    TextField(LocalizedStrings.baseURL, text: $baseURL)
                        .help(LocalizedStrings.baseURLHelp)
                        .disabled(useMock)
                        .opacity(useMock ? 0.5 : 1.0)

                    TextField(LocalizedStrings.model, text: $model)
                        .help(LocalizedStrings.modelHelp)
                        .disabled(useMock)
                        .opacity(useMock ? 0.5 : 1.0)
                }
            }
            .formStyle(.grouped)

            if showSaveConfirmation {
                Text(LocalizedStrings.configurationSavedSuccess)
                    .foregroundColor(.green)
                    .font(.caption)
            }

            HStack {
                Button(LocalizedStrings.restoreDefaults) {
                    baseURL = "https://openrouter.ai/api/v1/chat/completions"
                    model = "openai/gpt-4o"
                }

                Spacer()

                Button(LocalizedStrings.cancel) {
                    dismiss()
                }

                Button(LocalizedStrings.save) {
                    var mutableConfig = configuration
                    mutableConfig.openRouterAPIKey = apiKey
                    mutableConfig.openRouterBaseURL = baseURL
                    mutableConfig.openRouterModel = model
                    mutableConfig.useMockTranslation = useMock
                    showSaveConfirmation = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        showSaveConfirmation = false
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
    }
}

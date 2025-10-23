//
//  SettingsView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0

    let keychainManager: KeychainManagerProtocol
    let configuration: ConfigurationProtocol

    init(keychainManager: KeychainManagerProtocol, configuration: ConfigurationProtocol) {
        self.keychainManager = keychainManager
        self.configuration = configuration
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom tab selector
            Picker("", selection: $selectedTab) {
                Text(LocalizedStrings.appStoreAPI).tag(0)
                Text(LocalizedStrings.translationService).tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // Content
            Group {
                if selectedTab == 0 {
                    AppStoreAuthTab(keychainManager: keychainManager)
                } else {
                    TranslationServiceTab(configuration: configuration)
                }
            }
        }
        .frame(width: 700, height: 550)
    }
}
//
//  AppStoreAuthTab.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import SwiftUI

struct AppStoreAuthTab: View {
    @Environment(\.dismiss) var dismiss

    private let keychainManager: KeychainManagerProtocol

    @State private var issuerID = ""
    @State private var keyID = ""
    @State private var privateKey = ""
    @State private var showSaveConfirmation = false

    init(keychainManager: KeychainManagerProtocol) {
        self.keychainManager = keychainManager

        // Carrega credenciais do Keychain
        if let credentials = keychainManager.loadCredentials() {
            _issuerID = State(initialValue: credentials.issuerID)
            _keyID = State(initialValue: credentials.keyID)
            _privateKey = State(initialValue: credentials.privateKey)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStrings.authTitle)
                .font(.title2)
                .bold()

            Form {
                Section(LocalizedStrings.apiCredentials) {
                    TextField(LocalizedStrings.issuerID, text: $issuerID)
                    TextField(LocalizedStrings.keyID, text: $keyID)

                    VStack(alignment: .leading) {
                        Text(LocalizedStrings.privateKey)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $privateKey)
                            .frame(height: 120)
                            .font(.system(.body, design: .monospaced))
                            .border(Color.gray.opacity(0.3))
                    }
                }
            }
            .formStyle(.grouped)

            if showSaveConfirmation {
                Text(LocalizedStrings.credentialsSavedSuccess)
                    .foregroundColor(.green)
                    .font(.caption)
            }

            HStack {
                Button(LocalizedStrings.clearCredentials) {
                    keychainManager.deleteCredentials()
                    issuerID = ""
                    keyID = ""
                    privateKey = ""
                }
                .disabled(issuerID.isEmpty && keyID.isEmpty && privateKey.isEmpty)

                Spacer()

                Button(LocalizedStrings.cancel) {
                    dismiss()
                }

                Button(LocalizedStrings.save) {
                    try? keychainManager.save(
                        issuerID: issuerID,
                        keyID: keyID,
                        privateKey: privateKey
                    )
                    showSaveConfirmation = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        showSaveConfirmation = false
                        dismiss()
                    }
                }
                .disabled(issuerID.isEmpty || keyID.isEmpty || privateKey.isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
    }
}

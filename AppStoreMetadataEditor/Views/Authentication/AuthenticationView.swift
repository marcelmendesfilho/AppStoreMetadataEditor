//
//  AuthenticationView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var isPresented: Bool
    let onAuthenticate: (String, String, String) async -> Void
    let keychainManager: KeychainManagerProtocol

    @State private var issuerID = ""
    @State private var keyID = ""
    @State private var privateKey = ""
    @State private var errorMessage: String?

    init(
        isPresented: Binding<Bool>,
        keychainManager: KeychainManagerProtocol,
        onAuthenticate: @escaping (String, String, String) async -> Void
    ) {
        self._isPresented = isPresented
        self.keychainManager = keychainManager
        self.onAuthenticate = onAuthenticate

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
                .font(.title)

            TextField(LocalizedStrings.issuerID, text: $issuerID)
                .textFieldStyle(.roundedBorder)

            TextField(LocalizedStrings.keyID, text: $keyID)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $privateKey)
                .frame(height: 150)
                .border(Color.gray.opacity(0.3))
                .overlay(alignment: .topLeading) {
                    if privateKey.isEmpty {
                        Text(LocalizedStrings.privateKey)
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }

            HStack {
                Button(LocalizedStrings.cancel) {
                    isPresented = false
                }

                Button(LocalizedStrings.clearCredentials) {
                    keychainManager.deleteCredentials()
                    issuerID = ""
                    keyID = ""
                    privateKey = ""
                }
                .disabled(issuerID.isEmpty && keyID.isEmpty && privateKey.isEmpty)

                Spacer()

                Button(LocalizedStrings.authenticate) {
                    Task {
                        do {
                            // Salva no Keychain antes de autenticar
                            try keychainManager.save(
                                issuerID: issuerID,
                                keyID: keyID,
                                privateKey: privateKey
                            )
                            await onAuthenticate(issuerID, keyID, privateKey)
                            errorMessage = nil
                        } catch {
                            errorMessage = String(format: LocalizedStrings.errorSavingCredentials, error.localizedDescription)
                        }
                    }
                }
                .disabled(issuerID.isEmpty || keyID.isEmpty || privateKey.isEmpty)
                .buttonStyle(.borderedProminent)
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(30)
        .frame(width: 500)
    }
}

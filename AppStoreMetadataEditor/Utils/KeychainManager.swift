//
//  KeychainManager.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation
import Security

class KeychainManager: KeychainManagerProtocol {
    private let service = "com.marcelmendesfilho.AppStoreMetadataHandler"

    init() {}

    func save(issuerID: String, keyID: String, privateKey: String) throws {
        try saveItem(key: "issuerID", value: issuerID)
        try saveItem(key: "keyID", value: keyID)
        try saveItem(key: "privateKey", value: privateKey)
    }

    func loadCredentials() -> (issuerID: String, keyID: String, privateKey: String)? {
        guard let issuerID = loadItem(key: "issuerID"),
              let keyID = loadItem(key: "keyID"),
              let privateKey = loadItem(key: "privateKey") else {
            return nil
        }
        return (issuerID, keyID, privateKey)
    }

    func deleteCredentials() {
        deleteItem(key: "issuerID")
        deleteItem(key: "keyID")
        deleteItem(key: "privateKey")
    }

    private func saveItem(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Tenta deletar item existente
        SecItemDelete(query as CFDictionary)

        // Adiciona novo item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }

    private func loadItem(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func deleteItem(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

enum KeychainError: Error {
    case saveFailed
    case loadFailed
}

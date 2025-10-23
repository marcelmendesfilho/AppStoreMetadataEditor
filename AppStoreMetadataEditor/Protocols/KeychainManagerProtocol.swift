//
//  KeychainManagerProtocol.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import Foundation

protocol KeychainManagerProtocol {
    func save(issuerID: String, keyID: String, privateKey: String) throws
    func loadCredentials() -> (issuerID: String, keyID: String, privateKey: String)?
    func deleteCredentials()
}

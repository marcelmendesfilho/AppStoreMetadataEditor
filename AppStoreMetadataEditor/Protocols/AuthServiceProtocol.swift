//
//  AuthServiceProtocol.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var authToken: String? { get }

    func authenticate(issuerID: String, keyID: String, privateKey: String) async throws
    func clearAuthentication()
}

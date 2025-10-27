//
//  AuthServiceProtocol.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

protocol AuthServiceProtocol: Actor {
    var isAuthenticated: Bool { get async }
    var authToken: String? { get async }

    func authenticate(issuerID: String, keyID: String, privateKey: String) async throws
    func regenerateToken() async throws
    func clearAuthentication() async
}

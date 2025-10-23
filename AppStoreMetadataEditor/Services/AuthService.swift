//
//  AuthService.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation
import Combine
import CryptoKit

class AuthService: AuthServiceProtocol {
    @Published private(set) var isAuthenticated = false
    private(set) var authToken: String?

    private var issuerID: String?
    private var keyID: String?
    private var privateKey: String?

    func authenticate(issuerID: String, keyID: String, privateKey: String) async throws {
        self.issuerID = issuerID
        self.keyID = keyID
        self.privateKey = privateKey

        do {
            // Gera JWT token para App Store Connect API
            let token = try generateJWT()
            self.authToken = token
            self.isAuthenticated = true
        } catch {
            // Limpa credenciais em caso de erro
            self.issuerID = nil
            self.keyID = nil
            self.privateKey = nil
            throw error
        }
    }

    func clearAuthentication() {
        authToken = nil
        isAuthenticated = false
        issuerID = nil
        keyID = nil
        privateKey = nil
    }

    private func generateJWT() throws -> String {
        guard let issuerID = issuerID,
              let keyID = keyID,
              let privateKey = privateKey else {
            throw NetworkError.unauthorized
        }

        let header = JWTHeader(alg: "ES256", kid: keyID, typ: "JWT")
        let now = Date()
        let expiration = now.addingTimeInterval(20 * 60) // 20 minutos

        let payload = JWTPayload(
            iss: issuerID,
            iat: Int(now.timeIntervalSince1970),
            exp: Int(expiration.timeIntervalSince1970),
            aud: "appstoreconnect-v1"
        )

        let headerData = try JSONEncoder().encode(header)
        let payloadData = try JSONEncoder().encode(payload)

        let headerString = headerData.base64URLEncodedString()
        let payloadString = payloadData.base64URLEncodedString()
        let signingInput = "\(headerString).\(payloadString)"

        let signature = try signES256(data: signingInput.data(using: .utf8)!, privateKey: privateKey)
        let signatureString = signature.base64URLEncodedString()

        return "\(signingInput).\(signatureString)"
    }

    private func signES256(data: Data, privateKey: String) throws -> Data {
        do {
            let key = try P256.Signing.PrivateKey(pemRepresentation: privateKey)
            let signature = try key.signature(for: data)
            return signature.rawRepresentation
        } catch {
            throw AuthError.invalidPrivateKey
        }
    }
}

struct JWTHeader: Codable {
    let alg: String
    let kid: String
    let typ: String
}

struct JWTPayload: Codable {
    let iss: String
    let iat: Int
    let exp: Int
    let aud: String
}

enum AuthError: LocalizedError {
    case invalidPrivateKey

    var errorDescription: String? {
        switch self {
        case .invalidPrivateKey:
            return "Chave privada inválida. Verifique se está no formato PEM correto."
        }
    }
}

extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

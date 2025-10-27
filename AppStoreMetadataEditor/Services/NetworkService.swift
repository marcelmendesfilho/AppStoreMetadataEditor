//
//  NetworkService.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://api.appstoreconnect.apple.com/v1"
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func request<T: Decodable>(_ endpoint: String, method: HTTPMethod) async throws -> T {
        try await performRequest(endpoint, method: method, body: nil as String?)
    }

    func request<T: Decodable, B: Encodable>(_ endpoint: String, method: HTTPMethod, body: B) async throws -> T {
        try await performRequest(endpoint, method: method, body: body)
    }

    private func performRequest<T: Decodable, B: Encodable>(
        _ endpoint: String,
        method: HTTPMethod,
        body: B?,
        isRetry: Bool = false
    ) async throws -> T {
        // Se o endpoint já for uma URL completa, use diretamente
        let urlString: String
        if endpoint.hasPrefix("http") {
            urlString = endpoint
        } else {
            urlString = "\(baseURL)\(endpoint)"
        }

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = await authService.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            request.httpBody = try encoder.encode(body)

            // Log do request para updateLocalization
            if endpoint.contains("appStoreVersionLocalizations") && method == .patch {
                print("📤 [AppStoreConnect] UPDATE LOCALIZATION REQUEST")
                print("   URL: \(urlString)")
                print("   Method: \(method.rawValue)")
                if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
                    print("   Body:\n\(bodyString)")
                }
            }
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "", code: -1))
            }

            // Log detalhado para todos os erros HTTP
            if !(200...299).contains(httpResponse.statusCode) {
                print("❌ [AppStoreConnect] HTTP ERROR \(httpResponse.statusCode)")
                print("   URL: \(urlString)")
                print("   Method: \(method.rawValue)")
                if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
                    print("   Request Body:\n\(bodyString)")
                }
                if let responseString = String(data: data, encoding: .utf8) {
                    print("   Response Body:\n\(responseString)")
                }

                if httpResponse.statusCode == 401 {
                    // Tenta regenerar token apenas se não for retry
                    if !isRetry {
                        print("🔄 [NetworkService] 401 detected, attempting token regeneration...")

                        do {
                            try await authService.regenerateToken()
                            print("✅ [NetworkService] Token regenerated, retrying request...")

                            // Retry uma única vez com o novo token
                            return try await performRequest(endpoint, method: method, body: body, isRetry: true)
                        } catch {
                            print("❌ [NetworkService] Token regeneration failed: \(error)")
                            throw NetworkError.unauthorized
                        }
                    } else {
                        print("❌ [NetworkService] Retry attempt failed with 401 - credentials may be invalid")
                        throw NetworkError.unauthorized
                    }
                }
                throw NetworkError.serverError(httpResponse.statusCode)
            }

            // Log da resposta JSON bruta para chamadas de localizations
            if endpoint.contains("appStoreVersionLocalizations") {
                if method == .patch {
                    print("✅ [AppStoreConnect] UPDATE LOCALIZATION SUCCESS")
                    print("   Status Code: \(httpResponse.statusCode)")
                }
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 [AppStoreConnect] Response Body:")
                    print(jsonString)
                }
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

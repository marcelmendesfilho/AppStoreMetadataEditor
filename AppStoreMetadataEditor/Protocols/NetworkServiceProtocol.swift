//
//  NetworkServiceProtocol.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: String, method: HTTPMethod) async throws -> T
    func request<T: Decodable, B: Encodable>(_ endpoint: String, method: HTTPMethod, body: B) async throws -> T
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum NetworkError: LocalizedError {
    case invalidURL
    case unauthorized
    case decodingError
    case serverError(Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL inválida"
        case .unauthorized: return "Não autorizado - necessário autenticar"
        case .decodingError: return "Erro ao processar resposta"
        case .serverError(let code): return "Erro do servidor: \(code)"
        case .unknown(let error): return "Erro: \(error.localizedDescription)"
        }
    }
}

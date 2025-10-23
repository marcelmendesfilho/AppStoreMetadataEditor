//
//  AppIconService.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation
import SwiftUI
import AppKit

class AppIconService: AppIconServiceProtocol {
    private var cache: [String: NSImage] = [:]

    init() {}

    func fetchIcon(for bundleId: String) async -> Image? {
        // Verifica cache
        if let cachedImage = cache[bundleId] {
            return Image(nsImage: cachedImage)
        }

        return await fetchIconFromiTunes(bundleId: bundleId)
    }

    private func fetchIconFromiTunes(bundleId: String) async -> Image? {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(iTunesSearchResult.self, from: data)

            guard let artworkUrl = result.results.first?.artworkUrl512 ?? result.results.first?.artworkUrl100,
                  let iconURL = URL(string: artworkUrl) else {
                return nil
            }

            let (iconData, _) = try await URLSession.shared.data(from: iconURL)
            guard let nsImage = NSImage(data: iconData) else { return nil }

            // Cache a imagem
            cache[bundleId] = nsImage
            return Image(nsImage: nsImage)
        } catch {
            print("Erro ao buscar do iTunes: \(error)")
            return nil
        }
    }
}

// Estruturas para respostas da API
struct AppInfoResponse: Codable {
    let data: AppInfoData

    struct AppInfoData: Codable {
        let id: String
        let attributes: Attributes?

        struct Attributes: Codable {
            let bundleId: String?
        }
    }
}

struct AppInfoSetsResponse: Codable {
    let data: [AppInfo]

    struct AppInfo: Codable {
        let id: String
    }
}

struct AppInfoLocalizationsResponse: Codable {
    let data: [AppInfoLocalization]

    struct AppInfoLocalization: Codable {
        let id: String
    }
}

struct iTunesSearchResult: Codable {
    let resultCount: Int
    let results: [iTunesApp]

    struct iTunesApp: Codable {
        let artworkUrl512: String?
        let artworkUrl100: String?
        let artworkUrl60: String?
    }
}

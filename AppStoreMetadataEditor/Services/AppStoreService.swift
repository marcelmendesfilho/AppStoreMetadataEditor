//
//  AppStoreService.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

class AppStoreService: AppStoreServiceProtocol {
    let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchApps() async throws -> [AppStoreApp] {
        let response: AppsResponse = try await networkService.request(
            "/apps?include=appStoreVersions",
            method: .get
        )
        return response.data
    }

    func fetchVersions(for appID: String) async throws -> [AppVersion] {
        var allVersions: [AppVersion] = []
        var nextURL: String? = "/apps/\(appID)/appStoreVersions?include=appStoreVersionLocalizations&limit=200"

        // Itera por todas as páginas
        while let url = nextURL {
            let response: AppVersionsResponse = try await networkService.request(url, method: .get)
            allVersions.append(contentsOf: response.data)

            // Verifica se há próxima página
            nextURL = response.links?.next
        }

        return allVersions
    }

    func fetchLocalizations(for versionID: String) async throws -> [AppVersionLocalization] {
        print("📱 [AppStoreConnect] Fetching localizations for version: \(versionID)")

        var allLocalizations: [AppVersionLocalization] = []
        var nextURL: String? = "/appStoreVersions/\(versionID)/appStoreVersionLocalizations?limit=200"

        // Itera por todas as páginas
        while let url = nextURL {
            let response: AppVersionLocalizationResponse = try await networkService.request(url, method: .get)
            allLocalizations.append(contentsOf: response.data)

            // Log detalhado da primeira página (onde vem a ordem do primary language)
            if allLocalizations.count == response.data.count {
                print("📋 [AppStoreConnect] Localizations returned (in order):")
                for (index, loc) in response.data.enumerated() {
                    let isPrimary = index == 0 ? " ⭐️ PRIMARY" : ""
                    print("  [\(index + 1)] \(loc.attributes.locale)\(isPrimary)")
                }
            }

            // Verifica se há próxima página
            nextURL = response.links?.next
        }

        print("✅ [AppStoreConnect] Total localizations loaded: \(allLocalizations.count)")
        if let firstLocale = allLocalizations.first?.attributes.locale {
            print("🎯 [AppStoreConnect] Primary language (first returned): \(firstLocale)")
        }

        return allLocalizations
    }

    func updateLocalization(id: String, attributes: LocalizationAttributes) async throws -> AppVersionLocalization {
        // Converter para UpdateAttributes (sem locale)
        let updateAttributes = LocalizationUpdateAttributes(
            description: attributes.description,
            keywords: attributes.keywords,
            whatsNew: attributes.whatsNew,
            promotionalText: attributes.promotionalText,
            supportUrl: attributes.supportUrl,
            marketingUrl: attributes.marketingUrl
        )

        let request = AppVersionLocalizationUpdateRequest(
            data: .init(type: "appStoreVersionLocalizations", id: id, attributes: updateAttributes)
        )

        let response: SingleLocalizationResponse = try await networkService.request(
            "/appStoreVersionLocalizations/\(id)",
            method: .patch,
            body: request
        )
        return response.data
    }
}

// Helper structures
struct SingleLocalizationResponse: Codable {
    let data: AppVersionLocalization
}

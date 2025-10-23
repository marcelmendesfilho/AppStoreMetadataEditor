//
//  AppDetailViewModel.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation
import Combine

@MainActor
class AppDetailViewModel: ObservableObject {
    @Published var selectedPlatform: Platform?
    @Published var versions: [AppVersion] = []
    @Published var localizations: [String: [AppVersionLocalization]] = [:]
    @Published var baseLocales: [String: String] = [:] // versionID -> base locale
    @Published var isLoading = false
    @Published var errorMessage: String?

    let appStoreService: AppStoreServiceProtocol
    let app: AppDisplayData

    init(app: AppDisplayData, appStoreService: AppStoreServiceProtocol) {
        self.app = app
        self.appStoreService = appStoreService
        self.versions = app.versions
        self.selectedPlatform = app.platforms.first

        // Carrega localizações para todas as versões
        Task {
            await loadAllLocalizations()
        }
    }

    func loadAllLocalizations() async {
        for version in versions {
            await loadLocalizations(for: version)
        }
    }

    func getLocales(for versionID: String) -> [String] {
        guard let locs = localizations[versionID] else { return [] }

        let locales = locs.map { $0.attributes.locale }
        let baseLocale = baseLocales[versionID]

        // Ordena colocando o idioma base primeiro
        return locales.sorted { locale1, locale2 in
            if let base = baseLocale {
                if locale1 == base { return true }
                if locale2 == base { return false }
            }
            return locale1.localizedCaseInsensitiveCompare(locale2) == .orderedAscending
        }
    }

    func getBaseLocale(for versionID: String) -> String? {
        return baseLocales[versionID]
    }

    var filteredVersions: [AppVersion] {
        guard let platform = selectedPlatform else { return [] }
        return versions.filter { $0.attributes.platform == platform }
    }

    func loadLocalizations(for version: AppVersion) async {
        isLoading = true
        do {
            let locs = try await appStoreService.fetchLocalizations(for: version.id)
            localizations[version.id] = locs

            // Usar primaryLocale do app como idioma base
            if let primaryLocale = app.primaryLocale {
                baseLocales[version.id] = primaryLocale
                print("🎯 [AppDetailViewModel] Using app primaryLocale: \(primaryLocale)")
            } else {
                // Fallback: usar primeira localização retornada pela API
                if let firstLocale = locs.first?.attributes.locale {
                    baseLocales[version.id] = firstLocale
                    print("⚠️ [AppDetailViewModel] App has no primaryLocale, using first localization: \(firstLocale)")
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func updateLocalization(_ localization: AppVersionLocalization, with attributes: LocalizationAttributes) async {
        do {
            let updated = try await appStoreService.updateLocalization(id: localization.id, attributes: attributes)
            // Atualiza na lista local
            if var versionLocs = localizations[localization.id] {
                if let index = versionLocs.firstIndex(where: { $0.id == updated.id }) {
                    versionLocs[index] = updated
                    localizations[localization.id] = versionLocs
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

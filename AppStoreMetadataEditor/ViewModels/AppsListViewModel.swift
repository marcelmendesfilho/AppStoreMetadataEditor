//
//  AppsListViewModel.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AppsListViewModel: ObservableObject {
    @Published var apps: [AppDisplayData] = []
    @Published var searchText = ""
    @Published var showOnlyFavorites = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAuthSheet = false

    private let appStoreService: AppStoreServiceProtocol
    private let authService: AuthServiceProtocol
    private let keychainManager: KeychainManagerProtocol
    private let appIconService: AppIconServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol

    var filteredApps: [AppDisplayData] {
        var result = apps

        // Filtra por favoritos se ativado
        if showOnlyFavorites {
            result = result.filter { favoritesManager.isFavorite($0.id) }
        }

        // Filtra por busca
        if !searchText.isEmpty {
            result = result.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText) ||
                app.bundleId.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Ordena alfabeticamente
        return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func toggleFavorite(_ appID: String) {
        favoritesManager.toggleFavorite(appID)
        objectWillChange.send() // Força atualização da view
    }

    func isFavorite(_ appID: String) -> Bool {
        return favoritesManager.isFavorite(appID)
    }

    init(
        appStoreService: AppStoreServiceProtocol,
        authService: AuthServiceProtocol,
        keychainManager: KeychainManagerProtocol,
        appIconService: AppIconServiceProtocol,
        favoritesManager: FavoritesManagerProtocol
    ) {
        self.appStoreService = appStoreService
        self.authService = authService
        self.keychainManager = keychainManager
        self.appIconService = appIconService
        self.favoritesManager = favoritesManager
    }

    func tryAutoAuthenticate() async {
        // Tenta autenticar automaticamente com credenciais salvas
        if let credentials = keychainManager.loadCredentials() {
            try? await authService.authenticate(
                issuerID: credentials.issuerID,
                keyID: credentials.keyID,
                privateKey: credentials.privateKey
            )
        }
    }

    func loadApps() async {
        // Verifica se está autenticado antes de tentar carregar
        guard await authService.isAuthenticated else {
            showAuthSheet = true
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let fetchedApps = try await appStoreService.fetchApps()

            apps = await withTaskGroup(of: AppDisplayData?.self) { group in
                for app in fetchedApps {
                    group.addTask {
                        await self.createDisplayData(for: app)
                    }
                }

                var result: [AppDisplayData] = []
                for await displayData in group {
                    if let data = displayData {
                        result.append(data)
                    }
                }
                return result
            }
        } catch NetworkError.unauthorized {
            showAuthSheet = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshApps() async {
        apps = [] // Limpa a lista antes de recarregar
        await loadApps()
    }

    private func createDisplayData(for app: AppStoreApp) async -> AppDisplayData? {
        do {
            let versions = try await appStoreService.fetchVersions(for: app.id)
            // Ordenar plataformas alfabeticamente pelo displayName
            let platforms = Array(Set(versions.compactMap { $0.attributes.platform }))
                .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }

            // Busca o ícone usando o bundle ID
            let iconImage = await appIconService.fetchIcon(for: app.attributes.bundleId)

            // Log do primaryLocale
            if let primaryLocale = app.attributes.primaryLocale {
                print("🌍 [App] \(app.attributes.name) - Primary Locale: \(primaryLocale)")
            }

            return AppDisplayData(
                id: app.id,
                name: app.attributes.name,
                bundleId: app.attributes.bundleId,
                platforms: platforms,
                versions: versions,
                primaryLocale: app.attributes.primaryLocale,
                iconImage: iconImage
            )
        } catch {
            return nil
        }
    }

    func authenticate(issuerID: String, keyID: String, privateKey: String) async {
        do {
            try await authService.authenticate(issuerID: issuerID, keyID: keyID, privateKey: privateKey)
            showAuthSheet = false
            await loadApps()
        } catch {
            errorMessage = "Erro na autenticação: \(error.localizedDescription)"
        }
    }
}

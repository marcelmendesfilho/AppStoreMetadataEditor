//
//  DependencyContainer.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

@MainActor
class DependencyContainer {
    static let shared = DependencyContainer()

    // Core services
    private(set) lazy var keychainManager: KeychainManagerProtocol = KeychainManager()
    private(set) lazy var configuration: ConfigurationProtocol = Configuration()
    private(set) lazy var appIconService: AppIconServiceProtocol = AppIconService()
    private(set) lazy var favoritesManager: FavoritesManagerProtocol = FavoritesManager()

    // App Store services
    private(set) lazy var authService: AuthServiceProtocol = AuthService()
    private(set) lazy var networkService: NetworkServiceProtocol = NetworkService(authService: authService)
    private(set) lazy var appStoreService: AppStoreServiceProtocol = AppStoreService(networkService: networkService)

    // Translation service - computed property para verificar useMockTranslation em tempo real
    var translationService: TranslationServiceProtocol {
        if configuration.useMockTranslation {
            return MockTranslationService()
        } else {
            return TranslationService(configuration: configuration)
        }
    }

    func makeAppsListViewModel() -> AppsListViewModel {
        AppsListViewModel(
            appStoreService: appStoreService,
            authService: authService,
            keychainManager: keychainManager,
            appIconService: appIconService,
            favoritesManager: favoritesManager
        )
    }

    func makeAppDetailViewModel(app: AppDisplayData) -> AppDetailViewModel {
        AppDetailViewModel(app: app, appStoreService: appStoreService)
    }

    private init() {}
}

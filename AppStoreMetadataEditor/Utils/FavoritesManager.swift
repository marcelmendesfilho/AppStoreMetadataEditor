//
//  FavoritesManager.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

class FavoritesManager: FavoritesManagerProtocol {
    private let key = "favoriteApps"
    private var favorites: Set<String> = []

    init() {
        loadFavorites()
    }

    func isFavorite(_ appID: String) -> Bool {
        return favorites.contains(appID)
    }

    func toggleFavorite(_ appID: String) {
        if favorites.contains(appID) {
            favorites.remove(appID)
        } else {
            favorites.insert(appID)
        }
        saveFavorites()
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.array(forKey: key) as? [String] {
            favorites = Set(data)
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favorites), forKey: key)
    }
}

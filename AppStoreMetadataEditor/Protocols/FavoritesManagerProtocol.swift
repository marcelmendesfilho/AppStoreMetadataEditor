//
//  FavoritesManagerProtocol.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import Foundation

protocol FavoritesManagerProtocol {
    func isFavorite(_ appID: String) -> Bool
    func toggleFavorite(_ appID: String)
}

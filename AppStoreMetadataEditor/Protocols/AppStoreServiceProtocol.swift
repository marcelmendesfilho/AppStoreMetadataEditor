//
//  AppStoreServiceProtocol.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation

protocol AppStoreServiceProtocol {
    func fetchApps() async throws -> [AppStoreApp]
    func fetchVersions(for appID: String) async throws -> [AppVersion]
    func fetchLocalizations(for versionID: String) async throws -> [AppVersionLocalization]
    func updateLocalization(id: String, attributes: LocalizationAttributes) async throws -> AppVersionLocalization
}

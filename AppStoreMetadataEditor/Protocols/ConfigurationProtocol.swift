//
//  ConfigurationProtocol.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import Foundation

protocol ConfigurationProtocol {
    var openRouterAPIKey: String { get set }
    var openRouterBaseURL: String { get set }
    var openRouterModel: String { get set }
    var useMockTranslation: Bool { get set }
}

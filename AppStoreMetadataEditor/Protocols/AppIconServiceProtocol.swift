//
//  AppIconServiceProtocol.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import Foundation
import SwiftUI

protocol AppIconServiceProtocol {
    func fetchIcon(for bundleId: String) async -> Image?
}

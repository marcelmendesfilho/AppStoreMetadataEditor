//
//  AppStoreMetadataEditorApp.swift
//  AppStoreMetadataEditor
//
//  Created by Marcel Mendes on 21/10/25.
//

import SwiftUI

@main
struct AppStoreMetadataEditorApp: App {
    @StateObject private var appsListViewModel = DependencyContainer.shared.makeAppsListViewModel()
    @State private var showSettings = false

    var body: some Scene {
        WindowGroup {
            AppsListView(viewModel: appsListViewModel, showSettings: $showSettings)
                .frame(minWidth: 800, minHeight: 600)
                .sheet(isPresented: $showSettings) {
                    SettingsView(
                        keychainManager: DependencyContainer.shared.keychainManager,
                        configuration: DependencyContainer.shared.configuration
                    )
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            AppStoreMetadataEditorCommands(showSettings: $showSettings)
        }
    }
}

//
//  AppsListView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import SwiftUI

struct AppsListView: View {
    @StateObject var viewModel: AppsListViewModel
    @State private var selectedApp: AppDisplayData?
    @Binding var showSettings: Bool

    var body: some View {
        NavigationSplitView {
            List(viewModel.filteredApps, selection: $selectedApp) { app in
                NavigationLink(value: app) {
                    AppRowView(app: app)
                        .environmentObject(viewModel)
                }
            }
            .navigationTitle(LocalizedStrings.myApps)
            .searchable(
                text: $viewModel.searchText,
                placement: .sidebar,
                prompt: LocalizedStrings.searchApps
            )
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Toggle(isOn: $viewModel.showOnlyFavorites) {
                        Image(systemName: viewModel.showOnlyFavorites ? "star.fill" : "star")
                    }
                    .help(LocalizedStrings.showOnlyFavorites)
                    .toggleStyle(.button)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await viewModel.refreshApps()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        } detail: {
            if let app = selectedApp {
                AppDetailView(
                    app: app,
                    appStoreService: DependencyContainer.shared.appStoreService
                )
                .id(app.id) // Força recriação quando app muda
            } else {
                Text(LocalizedStrings.selectApp)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $viewModel.showAuthSheet) {
            AuthenticationView(
                isPresented: $viewModel.showAuthSheet,
                keychainManager: DependencyContainer.shared.keychainManager
            ) { issuerID, keyID, privateKey in
                await viewModel.authenticate(issuerID: issuerID, keyID: keyID, privateKey: privateKey)
            }
        }
        .alert(LocalizedStrings.error, isPresented: .constant(viewModel.errorMessage != nil)) {
            Button(LocalizedStrings.ok) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .task {
            // Tenta autenticar automaticamente com credenciais salvas
            await viewModel.tryAutoAuthenticate()

            if viewModel.apps.isEmpty {
                await viewModel.loadApps()
            }
        }
    }
}

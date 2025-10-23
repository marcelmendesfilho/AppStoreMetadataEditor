//
//  AppDetailView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import SwiftUI

struct AppDetailView: View {
    struct LocalizationsData: Identifiable {
        let id = UUID()
        let version: AppVersion
        let localizations: [AppVersionLocalization]
        let baseLocale: String?
    }

    struct VersionToEdit: Identifiable {
        let id = UUID()
        let version: AppVersion
        let platform: Platform
        let versionString: String?
    }

    let app: AppDisplayData
    @StateObject private var viewModel: AppDetailViewModel
    @State private var selectedVersion: AppVersion?
    @State private var versionToEdit: VersionToEdit?
    @State private var localizationsToShow: LocalizationsData?
    @State private var isLoadingLocalizations = false
    @State private var showTimeoutAlert = false

    init(app: AppDisplayData, appStoreService: AppStoreServiceProtocol) {
        self.app = app
        _viewModel = StateObject(wrappedValue: AppDetailViewModel(
            app: app,
            appStoreService: appStoreService
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Platform picker
            Picker(LocalizedStrings.platform, selection: $viewModel.selectedPlatform) {
                ForEach(app.platforms, id: \.self) { platform in
                    Text(platform.displayName).tag(platform as Platform?)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Versions list
            List(viewModel.filteredVersions) { version in
                VersionRowView(version: version, viewModel: viewModel)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedVersion = version

                        // Se a versão é editável (Prepare for Submission), abrir editor
                        if let state = version.attributes.appStoreState, state.isEditable,
                           let platform = version.attributes.platform {
                            versionToEdit = VersionToEdit(
                                version: version,
                                platform: platform,
                                versionString: version.attributes.versionString
                            )
                        } else {
                            // Caso contrário, mostrar localizações (read-only)
                            Task {
                                await loadLocalizationsAndShowPopup(for: version)
                            }
                        }
                    }
            }
        }
        .sheet(item: $versionToEdit) { data in
            VersionEditorSheet(
                app: app,
                platform: data.platform,
                mode: .edit(versionID: data.version.id),
                existingVersionString: data.versionString,
                isPresented: Binding(
                    get: { versionToEdit != nil },
                    set: { if !$0 { versionToEdit = nil } }
                )
            )
        }
        .sheet(item: $localizationsToShow) { data in
            VersionLocalizationsSheet(
                app: app,
                version: data.version,
                localizations: data.localizations,
                baseLocale: data.baseLocale,
                isPresented: Binding(
                    get: { localizationsToShow != nil },
                    set: { if !$0 { localizationsToShow = nil } }
                )
            )
        }
        .overlay {
            if isLoadingLocalizations {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(.circular)

                        Text(LocalizedStrings.loadingLocalizations)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
            }
        }
        .alert(LocalizedStrings.timeout, isPresented: $showTimeoutAlert) {
            Button(LocalizedStrings.ok) { }
        } message: {
            Text(LocalizedStrings.timeoutMessage)
        }
    }

    private func loadLocalizationsAndShowPopup(for version: AppVersion) async {
        isLoadingLocalizations = true

        do {
            // Tentar carregar localizações com timeout
            let locs = try await withTimeout(seconds: 60) {
                try await viewModel.appStoreService.fetchLocalizations(for: version.id)
            }

            // Ocultar loading
            isLoadingLocalizations = false

            // Só mostrar o popup se houver localizações carregadas
            if !locs.isEmpty {
                localizationsToShow = LocalizationsData(
                    version: version,
                    localizations: locs,
                    baseLocale: viewModel.getBaseLocale(for: version.id)
                )
            }

        } catch is TimeoutError {
            // Timeout ocorreu
            isLoadingLocalizations = false
            showTimeoutAlert = true

        } catch {
            // Outro erro ocorreu
            print("Erro ao carregar localizações: \(error)")
            isLoadingLocalizations = false
        }
    }

    private func withTimeout<T>(seconds: Int, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            // Task para executar a operação
            group.addTask {
                try await operation()
            }

            // Task para timeout
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
                throw TimeoutError()
            }

            // Retorna o primeiro resultado (ou erro)
            let result = try await group.next()!

            // Cancela as outras tasks
            group.cancelAll()

            return result
        }
    }
}


//
//  VersionEditorSheet.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import SwiftUI

struct VersionEditorSheet: View {
    let app: AppDisplayData
    let platform: Platform
    let mode: VersionEditorMode
    let existingVersionString: String?
    @Binding var isPresented: Bool

    @StateObject private var viewModel: VersionEditorViewModel
    @State private var selectedLocale: String?
    @State private var showCloseConfirmation = false

    init(app: AppDisplayData, platform: Platform, mode: VersionEditorMode, existingVersionString: String? = nil, isPresented: Binding<Bool>) {
        self.app = app
        self.platform = platform
        self.mode = mode
        self.existingVersionString = existingVersionString
        self._isPresented = isPresented

        _viewModel = StateObject(wrappedValue: VersionEditorViewModel(
            app: app,
            platform: platform,
            mode: mode,
            appStoreService: DependencyContainer.shared.appStoreService,
            translationService: DependencyContainer.shared.translationService
        ))
    }

    private var modeTitle: String {
        return LocalizedStrings.editVersion
    }

    var body: some View {
        content
    }

    private var header: some View {
        HStack(spacing: 16) {
            // Ícone do app
            if let icon = app.iconImage {
                icon
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(app.name)
                    .font(.title2)
                    .bold()

                HStack(spacing: 12) {
                    Text(modeTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    if let versionString = existingVersionString {
                        Text(versionString)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(platform.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(LocalizedStrings.close) {
                showCloseConfirmation = true
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var mainContent: some View {
        Group {
            if viewModel.isLoadingData {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)

                    Text(LocalizedStrings.loadingLatestVersionData)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.localizations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text(LocalizedStrings.couldNotLoadData)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HSplitView {
                    // Lista de idiomas
                    List(viewModel.sortedLocales, id: \.self, selection: $selectedLocale) { locale in
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)

                            Text(locale)
                                .font(.body)

                            Spacer()

                            // Chip "primário" para idioma primário
                            if locale == viewModel.baseLocale {
                                Text(LocalizedStrings.primary)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(4)
                            }
                            // Botão "Mirror primary" para idiomas inglês não-primários
                            else if viewModel.isNonPrimaryEnglish(locale) {
                                Button {
                                    viewModel.mirrorPrimaryLocale(locale)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 10))
                                        Text(LocalizedStrings.mirrorPrimary)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.15))
                                    .foregroundColor(.purple)
                                    .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                            // Botão "traduzir" para idiomas diferentes do base (não-inglês)
                            else if locale != viewModel.baseLocale && viewModel.hasFieldsToTranslate {
                                Button {
                                    Task {
                                        await viewModel.translateLocale(locale)
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 10))
                                        Text(LocalizedStrings.translate)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.isTranslating)
                                .opacity(viewModel.isTranslating ? 0.5 : 1.0)
                            }

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .tag(locale)
                    }
                    .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)

                    // Editor da localização selecionada
                    if let selectedLocale = selectedLocale,
                       let localization = viewModel.localizations[selectedLocale] {
                        LocalizationEditorView(
                            locale: selectedLocale,
                            localization: Binding(
                                get: { localization },
                                set: { viewModel.localizations[selectedLocale] = $0 }
                            ),
                            viewModel: viewModel
                        )
                        .frame(minWidth: 400)
                    } else {
                        VStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)

                            Text(LocalizedStrings.selectLanguage)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(minHeight: 400)
            }
        }
    }

    private var footer: some View {
        HStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Spacer()

            Button(LocalizedStrings.updateVersion) {
                Task {
                    await viewModel.updateVersion()
                }
            }
            .disabled(viewModel.isCreatingVersion)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var content: some View {
        VStack(spacing: 0) {
            header
            Divider()
            mainContent
            Divider()
            footer
        }
        .frame(minWidth: 800, idealWidth: 900, minHeight: 500, idealHeight: 600)
        .overlay {
            if viewModel.isCreatingVersion {
                ZStack {
                    Color.black.opacity(0.3)
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)

                        if let progress = viewModel.updateProgress {
                            // Mostra progresso detalhado da atualização
                            Text(progress)
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            // Mostra mensagem genérica
                            Text(LocalizedStrings.updatingVersion)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(24)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }
            }
        }
        .onAppear {
            Task {
                // Inicializar versionString
                if let versionString = existingVersionString {
                    viewModel.versionString = versionString
                }

                await viewModel.loadVersionData()
                selectedLocale = "en-US"
            }
        }
        .alert(LocalizedStrings.confirmation, isPresented: $showCloseConfirmation) {
            Button(LocalizedStrings.cancel, role: .cancel) { }
            Button(LocalizedStrings.close, role: .destructive) {
                isPresented = false
            }
        } message: {
            Text(LocalizedStrings.confirmCloseMessage)
        }
        .onChange(of: viewModel.versionCreatedSuccessfully) { oldValue, newValue in
            if newValue {
                // Aguardar um pouco antes de fechar automaticamente após criar versão
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPresented = false
                }
            }
        }
        .alert(LocalizedStrings.success, isPresented: $viewModel.showSuccessAlert) {
            Button(LocalizedStrings.ok) {
                // Só fecha se foi criação de versão, não tradução
                if viewModel.versionCreatedSuccessfully {
                    isPresented = false
                }
            }
        } message: {
            Text(viewModel.successMessage ?? LocalizedStrings.operationCompletedSuccess)
        }
        .alert(LocalizedStrings.error, isPresented: $viewModel.showErrorAlert) {
            Button(LocalizedStrings.ok) { }
        } message: {
            Text(viewModel.errorMessage ?? LocalizedStrings.error)
        }
    }
}

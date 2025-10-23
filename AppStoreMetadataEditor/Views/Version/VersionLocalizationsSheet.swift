//
//  VersionLocalizationsSheet.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import SwiftUI

struct VersionLocalizationsSheet: View {
    let app: AppDisplayData
    let version: AppVersion
    let localizations: [AppVersionLocalization]
    let baseLocale: String?
    @Binding var isPresented: Bool
    @State private var selectedLocale: String?

    private var sortedLocalizations: [AppVersionLocalization] {
        let sorted = localizations.sorted { loc1, loc2 in
            // Idioma base sempre primeiro
            if let base = baseLocale {
                if loc1.attributes.locale == base { return true }
                if loc2.attributes.locale == base { return false }
            }
            return loc1.attributes.locale < loc2.attributes.locale
        }
        return sorted
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
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

                    HStack(spacing: 8) {
                        Text("\(LocalizedStrings.version) \(version.attributes.versionString ?? "N/A")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let platform = version.attributes.platform {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(platform.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let state = version.attributes.appStoreState {
                        Text(state.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(state.color.opacity(0.2))
                            .foregroundColor(state.color)
                            .cornerRadius(6)
                    }
                }

                Spacer()

                Button(LocalizedStrings.close) {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            if localizations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "globe.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text(LocalizedStrings.noLocalizationsAvailable)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HSplitView {
                    // Lista de idiomas
                    List(sortedLocalizations, id: \.id, selection: $selectedLocale) { localization in
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)

                            Text(localization.attributes.locale)
                                .font(.body)

                            Spacer()

                            // Chip "primário" para idioma primário
                            if localization.attributes.locale == baseLocale {
                                Text(LocalizedStrings.primary)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(4)
                            }

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .tag(localization.attributes.locale)
                    }
                    .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)

                    // Detalhes da localização selecionada
                    if let selectedLocale = selectedLocale,
                       let localization = localizations.first(where: { $0.attributes.locale == selectedLocale }) {
                        LocalizationDetailView(localization: localization)
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
        .frame(minWidth: 800, idealWidth: 900, minHeight: 500, idealHeight: 600)
        .onAppear {
            // Seleciona a primeira localização da lista ordenada
            if selectedLocale == nil {
                selectedLocale = sortedLocalizations.first?.attributes.locale
            }
        }
    }
}

//
//  VersionRowView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import SwiftUI

struct VersionRowView: View {
    let version: AppVersion
    @ObservedObject var viewModel: AppDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(LocalizedStrings.version) \(version.attributes.versionString ?? "N/A")")
                        .font(.headline)

                    if let state = version.attributes.appStoreState {
                        Text(state.displayName)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(state.color.opacity(0.2))
                            .foregroundColor(state.color)
                            .cornerRadius(4)
                    }
                }

                Spacer()

                if let date = version.attributes.createdDate {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Chips de idiomas
            let locales = viewModel.getLocales(for: version.id)
            let primaryLocale = viewModel.app.primaryLocale
            if !locales.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(locales, id: \.self) { locale in
                        let isPrimary = locale == primaryLocale
                        Text(locale)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isPrimary ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                            .foregroundColor(isPrimary ? .green : .primary)
                            .cornerRadius(4)
                    }
                }
            } else {
                Text(LocalizedStrings.loading)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

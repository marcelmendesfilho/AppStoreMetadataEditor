//
//  AppRowView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import SwiftUI

struct AppRowView: View {
    let app: AppDisplayData
    @EnvironmentObject var viewModel: AppsListViewModel

    var body: some View {
        HStack {
            if let icon = app.iconImage {
                icon
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.headline)

//                Text(app.bundleId)
//                    .font(.caption)
//                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    ForEach(app.platforms, id: \.self) { platform in
                        Text(platform.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            Text("\(app.versions.count) \(LocalizedStrings.versions)")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                viewModel.toggleFavorite(app.id)
            } label: {
                Image(systemName: viewModel.isFavorite(app.id) ? "star.fill" : "star")
                    .foregroundColor(viewModel.isFavorite(app.id) ? .yellow : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

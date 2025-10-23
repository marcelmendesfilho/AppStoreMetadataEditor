//
//  LocalizationFieldView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import SwiftUI

struct LocalizationFieldView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label com estilo destacado
            HStack {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 3)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .kerning(0.5)
            }

            // Conteúdo com fundo e padding
            Text(content)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

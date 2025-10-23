//
//  EditableFieldView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import SwiftUI

enum FieldCharacterLimit {
    case promotionalText
    case description
    case keywords
    case whatsNew
    case none

    var maxLength: Int? {
        switch self {
        case .promotionalText: return 170
        case .description: return 4000
        case .keywords: return 100
        case .whatsNew: return 4000
        case .none: return nil
        }
    }
}

struct EditableFieldView: View {
    let title: String
    @Binding var content: String
    var height: CGFloat?
    var isTranslatable: Bool = false
    var shouldTranslate: Binding<Bool>?
    var characterLimit: FieldCharacterLimit = .none

    init(title: String, content: Binding<String>, height: CGFloat? = nil, isTranslatable: Bool = false, shouldTranslate: Binding<Bool>? = nil, characterLimit: FieldCharacterLimit = .none) {
        self.title = title
        self._content = content
        self.height = height
        self.isTranslatable = isTranslatable
        self.shouldTranslate = shouldTranslate
        self.characterLimit = characterLimit
    }

    private var isOverLimit: Bool {
        guard let maxLength = characterLimit.maxLength else { return false }
        return content.count > maxLength
    }

    private var characterCountColor: Color {
        guard let maxLength = characterLimit.maxLength else { return .secondary }
        let count = content.count
        if count > maxLength {
            return .red
        } else if count > Int(Double(maxLength) * 0.9) {
            return .orange
        }
        return .secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label com estilo destacado e checkbox
            HStack {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 3)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .kerning(0.5)

                if isTranslatable, let shouldTranslate = shouldTranslate {
                    Spacer()

                    Toggle(LocalizedStrings.translateField, isOn: shouldTranslate)
                        .toggleStyle(.checkbox)
                        .font(.caption)
                }
            }

            // Campo editável
            if let height = height {
                TextEditor(text: Binding(
                    get: { content },
                    set: { newValue in
                        if let maxLength = characterLimit.maxLength {
                            content = String(newValue.prefix(maxLength))
                        } else {
                            content = newValue
                        }
                    }
                ))
                    .font(.system(size: 13))
                    .frame(height: height)
                    .padding(8)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isOverLimit ? Color.red : Color.blue.opacity(0.3), lineWidth: 1)
                    )
            } else {
                TextField("", text: Binding(
                    get: { content },
                    set: { newValue in
                        if let maxLength = characterLimit.maxLength {
                            content = String(newValue.prefix(maxLength))
                        } else {
                            content = newValue
                        }
                    }
                ))
                    .font(.system(size: 13))
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isOverLimit ? Color.red : Color.blue.opacity(0.3), lineWidth: 1)
                    )
            }

            // Contador de caracteres
            if let maxLength = characterLimit.maxLength {
                HStack {
                    Spacer()
                    Text("\(content.count) / \(maxLength)")
                        .font(.caption)
                        .foregroundColor(characterCountColor)
                        .monospacedDigit()
                }
            }
        }
    }
}

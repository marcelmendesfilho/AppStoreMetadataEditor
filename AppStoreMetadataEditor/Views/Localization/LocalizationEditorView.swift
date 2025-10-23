//
//  LocalizationEditorView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import SwiftUI

struct LocalizationEditorView: View {
    let locale: String
    @Binding var localization: EditableLocalization
    @ObservedObject var viewModel: VersionEditorViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                EditableFieldView(
                    title: LocalizedStrings.promotionalText,
                    content: Binding(
                        get: { localization.promotionalText ?? "" },
                        set: { localization.promotionalText = $0 }
                    ),
                    height: 60,
                    isTranslatable: locale == viewModel.baseLocale && viewModel.hasMultipleLanguages,
                    shouldTranslate: (locale == viewModel.baseLocale && viewModel.hasMultipleLanguages) ? $viewModel.translatePromotionalText : nil,
                    characterLimit: .promotionalText
                )

                EditableFieldView(
                    title: LocalizedStrings.description,
                    content: Binding(
                        get: { localization.description ?? "" },
                        set: { localization.description = $0 }
                    ),
                    height: 120,
                    isTranslatable: locale == viewModel.baseLocale && viewModel.hasMultipleLanguages,
                    shouldTranslate: (locale == viewModel.baseLocale && viewModel.hasMultipleLanguages) ? $viewModel.translateDescription : nil,
                    characterLimit: .description
                )

                EditableFieldView(
                    title: LocalizedStrings.whatsNew,
                    content: Binding(
                        get: { localization.whatsNew ?? "" },
                        set: { localization.whatsNew = $0 }
                    ),
                    height: 100,
                    isTranslatable: locale == viewModel.baseLocale && viewModel.hasMultipleLanguages,
                    shouldTranslate: (locale == viewModel.baseLocale && viewModel.hasMultipleLanguages) ? $viewModel.translateWhatsNew : nil,
                    characterLimit: .whatsNew
                )

                EditableFieldView(
                    title: LocalizedStrings.keywords,
                    content: Binding(
                        get: { localization.keywords ?? "" },
                        set: { localization.keywords = $0 }
                    ),
                    height: 60,
                    isTranslatable: locale == viewModel.baseLocale && viewModel.hasMultipleLanguages,
                    shouldTranslate: (locale == viewModel.baseLocale && viewModel.hasMultipleLanguages) ? $viewModel.translateKeywords : nil,
                    characterLimit: .keywords
                )

                EditableFieldView(
                    title: LocalizedStrings.supportURL,
                    content: Binding(
                        get: { localization.supportUrl ?? "" },
                        set: { localization.supportUrl = $0 }
                    ),
                    isTranslatable: false,
                    shouldTranslate: nil
                )

                EditableFieldView(
                    title: LocalizedStrings.marketingURL,
                    content: Binding(
                        get: { localization.marketingUrl ?? "" },
                        set: { localization.marketingUrl = $0 }
                    ),
                    isTranslatable: false,
                    shouldTranslate: nil
                )
            }
            .padding()
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

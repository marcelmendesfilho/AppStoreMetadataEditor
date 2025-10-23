//
//  LocalizationDetailView.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import SwiftUI

struct LocalizationDetailView: View {
    let localization: AppVersionLocalization

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LocalizationFieldView(
                    title: LocalizedStrings.promotionalText,
                    content: localization.attributes.promotionalText ?? ""
                )

                LocalizationFieldView(
                    title: LocalizedStrings.description,
                    content: localization.attributes.description ?? ""
                )

                LocalizationFieldView(
                    title: LocalizedStrings.whatsNew,
                    content: localization.attributes.whatsNew ?? ""
                )

                LocalizationFieldView(
                    title: LocalizedStrings.keywords,
                    content: localization.attributes.keywords ?? ""
                )

                LocalizationFieldView(
                    title: LocalizedStrings.supportURL,
                    content: localization.attributes.supportUrl ?? ""
                )

                LocalizationFieldView(
                    title: LocalizedStrings.marketingURL,
                    content: localization.attributes.marketingUrl ?? ""
                )
            }
            .padding()
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

//
//  VersionEditorViewModel.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 21/10/25.
//

import Foundation
import Combine

enum VersionEditorMode: Equatable {
    case edit(versionID: String)
}

@MainActor
class VersionEditorViewModel: ObservableObject {
    @Published var versionString = ""
    @Published var localizations: [String: EditableLocalization] = [:] {
        didSet {
            refreshPendingLocalizationChanges()
        }
    }
    @Published var isLoadingData = false
    @Published var isCreatingVersion = false
    @Published var isTranslating = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showErrorAlert = false
    @Published var showSuccessAlert = false
    @Published var versionCreatedSuccessfully = false // Flag para fechar o sheet após criar versão
    @Published var baseLocale: String = "en-US" // Idioma base definido pela API
    @Published var updateProgress: String? // Progresso da atualização (ex: "Atualizando 3/10...")
    @Published var hasPendingLocalizationChanges = false

    let mode: VersionEditorMode

    // Checkboxes para seleção de campos a traduzir
    @Published var translatePromotionalText = true
    @Published var translateDescription = true
    @Published var translateWhatsNew = true
    @Published var translateKeywords = true

    var hasFieldsToTranslate: Bool {
        translatePromotionalText || translateDescription || translateWhatsNew || translateKeywords
    }

    var hasMultipleLanguages: Bool {
        localizations.count > 1
    }

    // Helper para detectar se um locale é inglês
    private func isEnglishLocale(_ locale: String) -> Bool {
        return locale.hasPrefix("en-")
    }

    // Verifica se há múltiplos idiomas inglês no app
    var hasMultipleEnglishLocales: Bool {
        let englishLocales = localizations.keys.filter { isEnglishLocale($0) }
        return englishLocales.count > 1
    }

    // Verifica se um locale específico é inglês mas não é o primário
    func isNonPrimaryEnglish(_ locale: String) -> Bool {
        return isEnglishLocale(locale) && locale != baseLocale && isEnglishLocale(baseLocale) && hasMultipleEnglishLocales
    }

    private let appStoreService: AppStoreServiceProtocol
    private let translationService: TranslationServiceProtocol
    private let app: AppDisplayData
    private let platform: Platform
    private var syncedLocalizations: [String: EditableLocalization] = [:]

    var sortedLocales: [String] {
        localizations.keys.sorted { locale1, locale2 in
            // Idioma base sempre primeiro
            if locale1 == baseLocale { return true }
            if locale2 == baseLocale { return false }
            return locale1.localizedCaseInsensitiveCompare(locale2) == .orderedAscending
        }
    }

    init(
        app: AppDisplayData,
        platform: Platform,
        mode: VersionEditorMode,
        appStoreService: AppStoreServiceProtocol,
        translationService: TranslationServiceProtocol
    ) {
        self.app = app
        self.platform = platform
        self.mode = mode
        self.appStoreService = appStoreService
        self.translationService = translationService
    }

    func loadVersionData() async {
        isLoadingData = true
        errorMessage = nil

        do {
            // Carregar a versão específica para edição
            let versionID: String
            switch mode {
            case .edit(let existingVersionID):
                versionID = existingVersionID
            }

            // Carregar localizações da versão com timeout
            let locs = try await withTimeout(seconds: 60) {
                try await self.appStoreService.fetchLocalizations(for: versionID)
            }

            let loadedLocalizations = locs.reduce(into: [String: EditableLocalization]()) { result, loc in
                var editable = EditableLocalization(from: loc.attributes)
                editable.id = loc.id // Guardar o ID da localização para update
                result[loc.attributes.locale] = editable
            }
            syncedLocalizations = loadedLocalizations
            localizations = loadedLocalizations

            // Usar primaryLocale do app como idioma base
            if let primaryLocale = app.primaryLocale {
                baseLocale = primaryLocale
                print("🎯 [VersionEditorViewModel] Using app primaryLocale: \(primaryLocale)")
            } else {
                // Fallback: usar primeira localização retornada pela API
                if let firstLocale = locs.first?.attributes.locale {
                    baseLocale = firstLocale
                    print("⚠️ [VersionEditorViewModel] App has no primaryLocale, using first localization: \(firstLocale)")
                }
            }

            refreshPendingLocalizationChanges()

        } catch is TimeoutError {
            errorMessage = LocalizedStrings.timeoutMessage
            showErrorAlert = true
        } catch {
            errorMessage = "Erro ao carregar dados: \(error.localizedDescription)"
            showErrorAlert = true
        }

        isLoadingData = false
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

    func mirrorPrimaryLocale(_ targetLocale: String) {
        guard let baseLocalization = localizations[baseLocale] else { return }

        // Copiar todos os campos do primary para o target
        localizations[targetLocale]?.promotionalText = baseLocalization.promotionalText
        localizations[targetLocale]?.description = baseLocalization.description
        localizations[targetLocale]?.whatsNew = baseLocalization.whatsNew
        localizations[targetLocale]?.keywords = baseLocalization.keywords
        localizations[targetLocale]?.supportUrl = baseLocalization.supportUrl
        localizations[targetLocale]?.marketingUrl = baseLocalization.marketingUrl

        successMessage = String(format: LocalizedStrings.mirrorCompleted, targetLocale, baseLocale)
        showSuccessAlert = true
    }

    func translateLocale(_ targetLocale: String) async {
        guard let baseLocalization = localizations[baseLocale] else { return }

        isTranslating = true
        errorMessage = nil

        do {
            // Preparar textos para traduzir baseado nos checkboxes
            var fieldsToTranslate: [String: String] = [:]

            if translatePromotionalText, let text = baseLocalization.promotionalText, !text.isEmpty {
                fieldsToTranslate["promotionalText"] = text
            }
            if translateDescription, let text = baseLocalization.description, !text.isEmpty {
                fieldsToTranslate["description"] = text
            }
            if translateWhatsNew, let text = baseLocalization.whatsNew, !text.isEmpty {
                fieldsToTranslate["whatsNew"] = text
            }
            if translateKeywords, let text = baseLocalization.keywords, !text.isEmpty {
                fieldsToTranslate["keywords"] = text
            }

            // Traduzir todos os campos de uma vez
            let fieldCharacterLimits = fieldsToTranslate.reduce(into: [String: Int]()) { result, entry in
                if let maxLength = LocalizationFieldLimits.maxLength(for: entry.key) {
                    result[entry.key] = maxLength
                }
            }

            let translatedFields = try await translationService.translateFields(
                fields: fieldsToTranslate,
                fieldCharacterLimits: fieldCharacterLimits,
                from: baseLocale,
                to: targetLocale
            )

            // Aplicar traduções
            if let promotionalText = translatedFields["promotionalText"] {
                localizations[targetLocale]?.promotionalText = promotionalText
            }
            if let description = translatedFields["description"] {
                localizations[targetLocale]?.description = description
            }
            if let whatsNew = translatedFields["whatsNew"] {
                localizations[targetLocale]?.whatsNew = whatsNew
            }
            if let keywords = translatedFields["keywords"] {
                localizations[targetLocale]?.keywords = keywords
            }

            successMessage = String(format: LocalizedStrings.translationCompleted, targetLocale)
            showSuccessAlert = true

        } catch {
            errorMessage = String(format: LocalizedStrings.errorTranslating, error.localizedDescription)
            showErrorAlert = true
        }

        isTranslating = false
    }

    func updateVersion() async {
        isCreatingVersion = true
        errorMessage = nil
        updateProgress = nil

        do {
            // Atualizar localizações existentes
            let localizationsToUpdate = localizations.filter { $0.value.hasContent && $0.value.id != nil }
            let totalCount = localizationsToUpdate.count
            var currentCount = 0
            var successCount = 0
            var failedLocales: [String] = []
            var successfulLocales: [String] = []

            print("🔄 [VersionEditorViewModel] Starting batch update of \(totalCount) localizations")

            for (locale, loc) in localizationsToUpdate {
                guard let localizationID = loc.id else { continue }

                currentCount += 1
                updateProgress = "Atualizando localização \(currentCount)/\(totalCount): \(locale)"

                do {
                    // IMPORTANTE: usar updateLocalization que já cria o objeto correto sem o campo 'locale'
                    let attributes = LocalizationAttributes(
                        locale: locale, // Será removido dentro de updateLocalization
                        description: loc.description,
                        keywords: loc.keywords,
                        whatsNew: loc.whatsNew,
                        promotionalText: loc.promotionalText,
                        supportUrl: loc.supportUrl,
                        marketingUrl: loc.marketingUrl
                    )

                    _ = try await appStoreService.updateLocalization(
                        id: localizationID,
                        attributes: attributes
                    )

                    successCount += 1
                    successfulLocales.append(locale)
                    print("✅ [VersionEditorViewModel] Updated \(locale) successfully (\(successCount)/\(totalCount))")

                } catch {
                    failedLocales.append(locale)
                    print("❌ [VersionEditorViewModel] Failed to update \(locale): \(error.localizedDescription)")
                }
            }

            updateProgress = nil

            if failedLocales.isEmpty {
                successMessage = "Versão atualizada com sucesso! \(successCount) localizações atualizadas."
                print("🎉 [VersionEditorViewModel] All localizations updated successfully!")
            } else {
                successMessage = "Versão parcialmente atualizada. \(successCount) de \(totalCount) localizações atualizadas.\nFalharam: \(failedLocales.joined(separator: ", "))"
                print("⚠️ [VersionEditorViewModel] Partial success: \(successCount)/\(totalCount) - Failed: \(failedLocales)")
            }

            markLocalesAsSynced(successfulLocales)

            showSuccessAlert = true
            versionCreatedSuccessfully = true // Marca para fechar o sheet

        } catch {
            errorMessage = String(format: LocalizedStrings.errorUpdatingVersion, error.localizedDescription)
            showErrorAlert = true
            print("💥 [VersionEditorViewModel] Error in updateVersion: \(error)")
        }

        updateProgress = nil
        isCreatingVersion = false
    }

    private func refreshPendingLocalizationChanges() {
        let allLocales = Set(localizations.keys).union(syncedLocalizations.keys)
        hasPendingLocalizationChanges = allLocales.contains { locale in
            guard let current = localizations[locale], let synced = syncedLocalizations[locale] else {
                return true
            }
            return !isEquivalent(current, synced)
        }
    }

    private func markLocalesAsSynced(_ locales: [String]) {
        guard !locales.isEmpty else { return }

        for locale in locales {
            syncedLocalizations[locale] = localizations[locale]
        }
        refreshPendingLocalizationChanges()
    }

    private func isEquivalent(_ lhs: EditableLocalization, _ rhs: EditableLocalization) -> Bool {
        normalize(lhs.promotionalText) == normalize(rhs.promotionalText) &&
        normalize(lhs.description) == normalize(rhs.description) &&
        normalize(lhs.whatsNew) == normalize(rhs.whatsNew) &&
        normalize(lhs.keywords) == normalize(rhs.keywords) &&
        normalize(lhs.supportUrl) == normalize(rhs.supportUrl) &&
        normalize(lhs.marketingUrl) == normalize(rhs.marketingUrl)
    }

    private func normalize(_ value: String?) -> String? {
        guard let value else { return nil }
        return value.isEmpty ? nil : value
    }
}

struct EditableLocalization {
    var id: String?
    var promotionalText: String?
    var description: String?
    var whatsNew: String?
    var keywords: String?
    var supportUrl: String?
    var marketingUrl: String?

    var hasContent: Bool {
        return !(promotionalText?.isEmpty ?? true) ||
               !(description?.isEmpty ?? true) ||
               !(whatsNew?.isEmpty ?? true) ||
               !(keywords?.isEmpty ?? true) ||
               !(supportUrl?.isEmpty ?? true) ||
               !(marketingUrl?.isEmpty ?? true)
    }

    init(from attributes: LocalizationAttributes) {
        self.promotionalText = attributes.promotionalText
        self.description = attributes.description
        self.whatsNew = attributes.whatsNew
        self.keywords = attributes.keywords
        self.supportUrl = attributes.supportUrl
        self.marketingUrl = attributes.marketingUrl
    }

    init() {}
}

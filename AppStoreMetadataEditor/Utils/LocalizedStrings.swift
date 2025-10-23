//
//  LocalizedStrings.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 22/10/25.
//

import Foundation

struct LocalizedStrings {
    // MARK: - Common Actions
    static let cancel = NSLocalizedString("cancel", value: "Cancel", comment: "Cancel action")
    static let save = NSLocalizedString("save", value: "Save", comment: "Save action")
    static let close = NSLocalizedString("close", value: "Close", comment: "Close action")
    static let ok = NSLocalizedString("ok", value: "OK", comment: "OK button")
    static let error = NSLocalizedString("error", value: "Error", comment: "Error title")
    static let success = NSLocalizedString("success", value: "Success", comment: "Success title")
    static let loading = NSLocalizedString("loading", value: "Loading...", comment: "Loading indicator")

    // MARK: - Authentication
    static let authTitle = NSLocalizedString("auth.title", value: "App Store Connect Authentication", comment: "Authentication view title")
    static let issuerID = NSLocalizedString("auth.issuer_id", value: "Issuer ID", comment: "Issuer ID field")
    static let keyID = NSLocalizedString("auth.key_id", value: "Key ID", comment: "Key ID field")
    static let privateKey = NSLocalizedString("auth.private_key", value: "Private Key (PEM format)", comment: "Private key field")
    static let authenticate = NSLocalizedString("auth.authenticate", value: "Authenticate", comment: "Authenticate button")
    static let clearCredentials = NSLocalizedString("auth.clear_credentials", value: "Clear Credentials", comment: "Clear credentials button")
    static let credentialsSavedSuccess = NSLocalizedString("auth.credentials_saved", value: "✓ Credentials saved successfully", comment: "Credentials saved confirmation")
    static let errorSavingCredentials = NSLocalizedString("auth.error_saving", value: "Error saving credentials: %@", comment: "Error saving credentials message")
    static let apiCredentials = NSLocalizedString("auth.api_credentials", value: "API Credentials", comment: "API credentials section title")

    // MARK: - Apps List
    static let myApps = NSLocalizedString("apps.my_apps", value: "My Apps", comment: "Apps list title")
    static let searchApps = NSLocalizedString("apps.search", value: "Search apps by name or bundle ID", comment: "Search apps prompt")
    static let selectApp = NSLocalizedString("apps.select", value: "Select an app", comment: "Select app placeholder")
    static let versions = NSLocalizedString("apps.versions", value: "versions", comment: "Versions count label")
    static let showOnlyFavorites = NSLocalizedString("apps.show_favorites", value: "Show only favorites", comment: "Show favorites tooltip")

    // MARK: - App Detail
    static let platform = NSLocalizedString("app_detail.platform", value: "Platform", comment: "Platform picker label")
    static let loadingLocalizations = NSLocalizedString("app_detail.loading_localizations", value: "Loading localizations...", comment: "Loading localizations message")
    static let timeout = NSLocalizedString("app_detail.timeout", value: "Timeout", comment: "Timeout alert title")
    static let timeoutMessage = NSLocalizedString("app_detail.timeout_message", value: "The operation took too long and was cancelled. Check your connection and try again.", comment: "Timeout alert message")
    static let noLocalizationsAvailable = NSLocalizedString("app_detail.no_localizations", value: "No localizations available", comment: "No localizations message")
    static let selectLanguage = NSLocalizedString("app_detail.select_language", value: "Select a language", comment: "Select language placeholder")

    // MARK: - Version Editor
    static let version = NSLocalizedString("version.version", value: "Version", comment: "Version label")
    static let updateVersion = NSLocalizedString("version.update", value: "Update Version", comment: "Update version button")
    static let updatingVersion = NSLocalizedString("version.updating", value: "Updating version...", comment: "Updating version message")
    static let editVersion = NSLocalizedString("version.edit", value: "Edit Version", comment: "Edit version title")
    static let errorUpdatingVersion = NSLocalizedString("version.error_updating", value: "Error updating version: %@", comment: "Error updating version message")
    static let loadingLatestVersionData = NSLocalizedString("version.loading_data", value: "Loading latest version data...", comment: "Loading version data message")
    static let couldNotLoadData = NSLocalizedString("version.could_not_load", value: "Could not load data", comment: "Could not load data message")
    static let primary = NSLocalizedString("version.primary", value: "primary", comment: "Primary language chip label")
    static let translate = NSLocalizedString("version.translate", value: "Translate", comment: "Translate button")
    static let mirrorPrimary = NSLocalizedString("version.mirror_primary", value: "Mirror primary", comment: "Mirror primary button")
    static let translationCompleted = NSLocalizedString("version.translation_completed", value: "Translation to %@ completed successfully!", comment: "Translation completed message")
    static let mirrorCompleted = NSLocalizedString("version.mirror_completed", value: "Content mirrored from %2$@ to %1$@ successfully!", comment: "Mirror completed message")
    static let errorTranslating = NSLocalizedString("version.error_translating", value: "Translation error: %@", comment: "Translation error message")
    static let confirmation = NSLocalizedString("version.confirmation", value: "Confirmation", comment: "Confirmation dialog title")
    static let confirmCloseMessage = NSLocalizedString("version.confirm_close", value: "All changes will be lost. Do you really want to close?", comment: "Confirm close message")
    static let operationCompletedSuccess = NSLocalizedString("version.operation_completed", value: "Operation completed successfully!", comment: "Operation completed message")

    // MARK: - App Store States
    static let statePrepareForSubmission = NSLocalizedString("state.prepare_for_submission", value: "Prepare for Submission", comment: "Prepare for submission state")
    static let stateWaitingForReview = NSLocalizedString("state.waiting_for_review", value: "Waiting for Review", comment: "Waiting for review state")
    static let stateInReview = NSLocalizedString("state.in_review", value: "In Review", comment: "In review state")
    static let statePendingDeveloperRelease = NSLocalizedString("state.pending_developer_release", value: "Pending Developer Release", comment: "Pending developer release state")
    static let stateReadyForSale = NSLocalizedString("state.ready_for_sale", value: "Ready for Sale", comment: "Ready for sale state")
    static let stateRejected = NSLocalizedString("state.rejected", value: "Rejected", comment: "Rejected state")
    static let stateMetadataRejected = NSLocalizedString("state.metadata_rejected", value: "Metadata Rejected", comment: "Metadata rejected state")
    static let stateRemovedFromSale = NSLocalizedString("state.removed_from_sale", value: "Removed from Sale", comment: "Removed from sale state")
    static let stateDeveloperRemovedFromSale = NSLocalizedString("state.developer_removed_from_sale", value: "Developer Removed from Sale", comment: "Developer removed from sale state")
    static let statePendingAppleRelease = NSLocalizedString("state.pending_apple_release", value: "Pending Apple Release", comment: "Pending Apple release state")
    static let stateProcessingForAppStore = NSLocalizedString("state.processing_for_app_store", value: "Processing for App Store", comment: "Processing for App Store state")
    static let stateReplacedWithNewVersion = NSLocalizedString("state.replaced_with_new_version", value: "Replaced with New Version", comment: "Replaced with new version state")
    static let stateInvalidBinary = NSLocalizedString("state.invalid_binary", value: "Invalid Binary", comment: "Invalid binary state")

    // MARK: - Localization Fields
    static let promotionalText = NSLocalizedString("localization.promotional_text", value: "Promotional Text", comment: "Promotional text field")
    static let description = NSLocalizedString("localization.description", value: "Description", comment: "Description field")
    static let whatsNew = NSLocalizedString("localization.whats_new", value: "What's New", comment: "What's new field")
    static let keywords = NSLocalizedString("localization.keywords", value: "Keywords", comment: "Keywords field")
    static let supportURL = NSLocalizedString("localization.support_url", value: "Support URL", comment: "Support URL field")
    static let marketingURL = NSLocalizedString("localization.marketing_url", value: "Marketing URL", comment: "Marketing URL field")
    static let translateField = NSLocalizedString("localization.translate_field", value: "Translate", comment: "Translate field checkbox")

    // MARK: - Settings
    static let settingsTitle = NSLocalizedString("settings.title", value: "Settings", comment: "Settings window title")
    static let appStoreAPI = NSLocalizedString("settings.app_store_api", value: "App Store API", comment: "App Store API tab")
    static let translationService = NSLocalizedString("settings.translation_service", value: "Translation Service", comment: "Translation Service tab")
    static let translationServiceTitle = NSLocalizedString("settings.translation_service_title", value: "Translation Service (OpenRouter)", comment: "Translation service title")
    static let operationMode = NSLocalizedString("settings.operation_mode", value: "Operation Mode", comment: "Operation mode section")
    static let useMock = NSLocalizedString("settings.use_mock", value: "Use Mock", comment: "Use mock toggle")
    static let useMockHelp = NSLocalizedString("settings.use_mock_help", value: "When enabled, uses a mock service to avoid consuming API credits", comment: "Use mock help text")
    static let apiConfiguration = NSLocalizedString("settings.api_configuration", value: "API Configuration", comment: "API configuration section")
    static let apiKey = NSLocalizedString("settings.api_key", value: "API Key", comment: "API key field")
    static let apiKeyHelp = NSLocalizedString("settings.api_key_help", value: "Your OpenRouter API key", comment: "API key help text")
    static let baseURL = NSLocalizedString("settings.base_url", value: "Base URL", comment: "Base URL field")
    static let baseURLHelp = NSLocalizedString("settings.base_url_help", value: "API base URL (default: https://openrouter.ai/api/v1/chat/completions)", comment: "Base URL help text")
    static let model = NSLocalizedString("settings.model", value: "Model", comment: "Model field")
    static let modelHelp = NSLocalizedString("settings.model_help", value: "Model to use (default: openai/gpt-4o)", comment: "Model help text")
    static let restoreDefaults = NSLocalizedString("settings.restore_defaults", value: "Restore Defaults", comment: "Restore defaults button")
    static let configurationSavedSuccess = NSLocalizedString("settings.saved_success", value: "✓ Configuration saved successfully", comment: "Configuration saved confirmation")
}

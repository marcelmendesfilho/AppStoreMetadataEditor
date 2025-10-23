//
//  AppStoreMetadataEditorCommands.swift
//  AppStoreMetadataEditor
//
//  Created by Claude Code on 23/10/25.
//

import SwiftUI

struct AppStoreMetadataEditorCommands: Commands {
    @Binding var showSettings: Bool

    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("Settings...") {
                showSettings = true
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}

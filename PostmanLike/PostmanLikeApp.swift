//
//  PostmanLikeApp.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI

@main
struct PostmanLikeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .commands {
            SidebarCommands()
            CommandGroup(after: .newItem) {
                Button("Import from Postman") {
                    appState.showImportPostman = true
                }
                
                Button("Export Project") {
                    appState.exportProject()
                }
                
                Button("Load Project") {
                    appState.showLoadProject = true
                }
                Button("Save") {
                    NotificationCenter.default.post(name: .save, object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }
}
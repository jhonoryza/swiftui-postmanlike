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
                Button("New Collection") {
                    appState.addNewCollection()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                
                Button("New Group") {
                    appState.addNewGroup()
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Import from Postman") {
                    appState.showImportPostman = true
                }
                
                Button("Export Project") {
                    appState.exportProject()
                }
                
                Button("Load Project") {
                    appState.showLoadProject = true
                }
            }
        }
        .windowStyle(TitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
    }
}

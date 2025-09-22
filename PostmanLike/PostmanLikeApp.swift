
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
                .sheet(isPresented: $appState.showImportPostman) {
                    ImportPostmanView()
                        .environmentObject(appState)
                }
                .sheet(isPresented: $appState.showExportProject) {
                    ExportProjectView()
                        .environmentObject(appState)
                }
                .sheet(isPresented: $appState.showLoadProject) {
                    LoadProjectView()
                        .environmentObject(appState)
                }
                .sheet(isPresented: $appState.showSaveProject) {
                    SaveProjectView()
                        .environmentObject(appState)
                }
        }
        .commands {
            SidebarCommands()
            CommandGroup(after: .newItem) {
                Button("Import from Postman") {
                    appState.showImportPostman = true
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Button("Export Project") {
                    appState.showExportProject = true
                }
                .keyboardShortcut("e", modifiers: .command)
                
                Button("Open Project") {
                    appState.showLoadProject = true
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Save Project") {
                    appState.showSaveProject = true
                }
                .keyboardShortcut("s", modifiers: [.shift, .command])
                
                Button("Save Request") {
                    NotificationCenter.default.post(name: .save, object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }
}

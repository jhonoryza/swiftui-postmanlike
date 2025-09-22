
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
                    ImportPostmanView(isPresented: $appState.showImportPostman)
                        .environmentObject(appState)
                }
                .sheet(isPresented: $appState.showExportProject) {
                    ExportProjectView(isPresented: $appState.showExportProject)
                        .environmentObject(appState)
                }
                .sheet(isPresented: $appState.showLoadProject) {
                    LoadProjectView(isPresented: $appState.showLoadProject)
                        .environmentObject(appState)
                }
                .sheet(isPresented: $appState.showSaveProject) {
                    SaveProjectView(isPresented: $appState.showSaveProject)
                        .environmentObject(appState)
                }
        }
        .commands {
            SidebarCommands()
            CommandGroup(after: .newItem) {
                Button("Import Postman Collection") {
                    appState.showImportPostman = true
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Button("Export as Postman Collection") {
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

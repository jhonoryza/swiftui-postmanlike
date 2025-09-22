
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
                .sheet(isPresented: $appState.showExportPostman) {
                    ExportPostmanView(isPresented: $appState.showExportPostman)
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
                .sheet(isPresented: $appState.showImportEnvironments) {
                    ImportEnvironmentsView(isPresented: $appState.showImportEnvironments)
                        .environmentObject(appState)
                }
                .sheet(isPresented: $appState.showExportEnvironments) {
                    ExportEnvironmentsView()
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
                    appState.showExportPostman = true
                }
                .keyboardShortcut("e", modifiers: .command)
                
                Button("Import Environments") {
                    appState.showImportEnvironments = true
                }
                
                Button("Export Environments") {
                    appState.showExportEnvironments = true
                }
                
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

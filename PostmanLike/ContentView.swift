//
//  ContentView.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HSplitView {
            // Left sidebar - Collections and Environments
            SidebarView()
                .frame(minWidth: 150)
            
            // Middle - Request editor
            MainView()
                .frame(minWidth: 400)
            
            // Right sidebar - Response viewer
            ResponseView()
                .frame(minWidth: 450)
        }
        .sheet(isPresented: $appState.showImportPostman) {
            ImportPostmanView()
        }
        .sheet(isPresented: $appState.showLoadProject) {
            LoadProjectView()
        }
    }
}

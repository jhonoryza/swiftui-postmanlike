
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
        NavigationView {
            SidebarView()
            
            // if appState.selectedRequest != nil {
                HSplitView {
                    MainView()
                        .frame(minWidth: 400)
                    ResponseView()
                        .frame(minWidth: 450)
                }
            // } else {
            //     Text("Select a request to begin")
            //         .foregroundColor(.secondary)
            //         .frame(maxWidth: .infinity, maxHeight: .infinity)
            // }
        }
    }
}

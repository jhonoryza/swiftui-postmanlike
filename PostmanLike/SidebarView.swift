//
//  SidebarView.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingNewEnvironment = false
    @State private var newEnvironmentName = ""
    
    var body: some View {
        VStack {
            List {
                Section("Environments") {
                    ForEach(appState.environments) { environment in
                        HStack {
                            Text(environment.name)
                            Spacer()
                            if appState.currentEnvironment?.id == environment.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appState.currentEnvironment = environment
                        }
                        .contextMenu {
                            Button("Delete") {
                                if appState.environments.count > 1 {
                                    appState.environments.removeAll { $0.id == environment.id }
                                    if appState.currentEnvironment?.id == environment.id {
                                        appState.currentEnvironment = appState.environments.first
                                    }
                                }
                            }
                            .disabled(appState.environments.count <= 1)
                        }
                    }
                }
                
                Section("Collections") {
                    NavigationStack() {                        
                        ForEach(appState.collections) { collection in
                            NavigationLink(value: collection) {
                                Text(collection.name)
                            }
                            .contextMenu {
                                Button("Delete") {
                                    appState.deleteCollection(collection)
                                }
                            }
                        }
                    }
                }
                
                Section("Groups") {
                    ForEach(appState.groups) { group in
                        DisclosureGroup(group.name) {
                            ForEach(group.collections) { collection in
                                Text(collection.name)
                                    .padding(.leading)
                            }
                        }
                        .contextMenu {
                            Button("Delete Group") {
                                appState.deleteGroup(group)
                            }
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationDestination(for: RequestCollection.self) { collection in
                CollectionDetailView(collection: collection)
            }
            
            HStack {
                Button(action: {
                    appState.addNewCollection()
                }) {
                    Image(systemName: "plus")
                }
                .help("New Collection")
                
                Button(action: {
                    appState.addNewGroup()
                }) {
                    Image(systemName: "folder.badge.plus")
                }
                .help("New Group")
                
                Button(action: {
                    showingNewEnvironment = true
                }) {
                    Image(systemName: "gearshape")
                }
                .help("New Environment")
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingNewEnvironment) {
            VStack {
                Text("New Environment")
                    .font(.headline)
                    .padding()
                
                TextField("Environment Name", text: $newEnvironmentName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("Cancel") {
                        showingNewEnvironment = false
                        newEnvironmentName = ""
                    }
                    
                    Button("Create") {
                        if !newEnvironmentName.isEmpty {
                            let newEnv = AppEnvironment(name: newEnvironmentName)
                            appState.environments.append(newEnv)
                            showingNewEnvironment = false
                            newEnvironmentName = ""
                        }
                    }
                    .disabled(newEnvironmentName.isEmpty)
                }
                .padding()
            }
            .padding()
            .frame(width: 300)
        }
    }
}

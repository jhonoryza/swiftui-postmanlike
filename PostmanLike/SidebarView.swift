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
    @State private var renamingRequest: Request? = nil
    @State private var newRequestName = ""
    @State private var renamingGroup: RequestGroup? = nil
    @State private var newGroupName = ""
    @State private var showingNewGroup = false
    @State private var selectedGroup: RequestGroup? = nil

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
                
                Section("Groups") {
                    ForEach($appState.groups) { $group in
                        DisclosureGroup(isExpanded: .constant(true)) {
                            ForEach(group.requests) { request in
                                HStack {
                                    if renamingRequest?.id == request.id {
                                        TextField("New Name", text: $newRequestName, onCommit: {
                                            if let index = group.requests.firstIndex(where: { $0.id == request.id }) {
                                                group.requests[index].name = newRequestName
                                            }
                                            renamingRequest = nil
                                        })
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        Text(request.name)
                                            .onTapGesture(count: 2) {
                                                renamingRequest = request
                                                newRequestName = request.name
                                            }
                                            .onTapGesture {
                                                appState.selectedRequest = request
                                                selectedGroup = nil
                                            }
                                    }
                                    Spacer()
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            appState.deleteRequest(request)
                                        }
                                }
                                .padding(.leading)
                                .background(appState.selectedRequest?.id == request.id ? Color.accentColor.opacity(0.5) : Color.clear)
                                .cornerRadius(5)
                            }
                        } label: {
                            if renamingGroup?.id == group.id {
                                TextField("New Name", text: $newGroupName, onCommit: {
                                    if let index = appState.groups.firstIndex(where: { $0.id == group.id }) {
                                        appState.groups[index].name = newGroupName
                                    }
                                    renamingGroup = nil
                                })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                Text(group.name)
                                    .font(.headline)
                                    .onTapGesture(count: 2) {
                                        renamingGroup = group
                                        newGroupName = group.name
                                    }
                                    .onTapGesture {
                                        selectedGroup = group
                                    }
                            }
                        }
                        // .background(selectedGroup?.id == group.id ? Color.accentColor.opacity(0.5) : Color.clear)
                        .cornerRadius(5)
                        .contextMenu {
                            Button("Add New Request") {
                                appState.addNewRequest(to: group)
                            }
                            Button("Delete Group") {
                                appState.deleteGroup(group)
                            }
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            
            HStack {
                Button(action: {
                    showingNewGroup = true
                }) {
                    Label("New Group", systemImage: "plus")
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingNewGroup) {
            VStack {
                Text("New Group")
                    .font(.headline)
                    .padding()
                
                TextField("Group Name", text: $newGroupName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("Cancel") {
                        showingNewGroup = false
                        newGroupName = ""
                    }
                    
                    Button("Create") {
                        if !newGroupName.isEmpty {
                            appState.addNewGroup(name: newGroupName)
                            showingNewGroup = false
                            newGroupName = ""
                        }
                    }
                    .disabled(newGroupName.isEmpty)
                }
                .padding()
            }
            .padding()
            .frame(width: 300)
        }
    }
}

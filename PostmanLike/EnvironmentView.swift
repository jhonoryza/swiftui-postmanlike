//
//  EnvironmentView.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI

struct EnvironmentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedEnvironmentId: UUID?

    var body: some View {
        VStack {
            HStack {
                Picker("Environment", selection: $selectedEnvironmentId) {
                    Text("No Environment").tag(nil as UUID?)
                    ForEach(appState.environments) { environment in
                        Text(environment.name).tag(environment.id as UUID?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Button(action: {
                    let newEnv = AppEnvironment(name: "New Environment")
                    appState.environments.append(newEnv)
                    selectedEnvironmentId = newEnv.id
                }) {
                    Image(systemName: "plus")
                }
            }
            .padding()

            if let selectedId = selectedEnvironmentId, let envIndex = appState.environments.firstIndex(where: { $0.id == selectedId }) {
                EnvironmentDetailView(environment: $appState.environments[envIndex])
            } else {
                Text("Select an environment to manage variables.")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            selectedEnvironmentId = appState.currentEnvironment?.id
        }
        .onChange(of: selectedEnvironmentId) { newId in
            appState.currentEnvironment = appState.environments.first { $0.id == newId }
        }
    }
}

struct EnvironmentDetailView: View {
    @Binding var environment: AppEnvironment
    @State private var newKey: String = ""
    @State private var newValue: String = ""

    var body: some View {
        VStack {
            HStack {
                TextField("Environment Name", text: $environment.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                Button(action: {
                    // Delete environment
                }) {
                    Image(systemName: "trash")
                }
            }
            .padding()

            List {
                ForEach(environment.variables.keys.sorted(), id: \.self) { key in
                    HStack {
                        TextField("Key", text: .constant(key))
                        TextField("Value", text: Binding(
                            get: { environment.variables[key] ?? "" },
                            set: { environment.variables[key] = $0 }
                        ))
                        Button(action: {
                            environment.variables.removeValue(forKey: key)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                HStack {
                    TextField("New Key", text: $newKey)
                    TextField("New Value", text: $newValue)
                    Button(action: {
                        if !newKey.isEmpty {
                            environment.variables[newKey] = newValue
                            newKey = ""
                            newValue = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}
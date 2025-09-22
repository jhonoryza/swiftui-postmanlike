//
//  ImportExportViews.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportPostmanView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var importedFile: URL?
    
    var body: some View {
        VStack {
            Text("Import Postman Collection")
                .font(.headline)
                .padding()
            
            Text("Drag and drop your Postman export file here or click to select")
                .frame(width: 400, height: 200)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    guard let provider = providers.first else { return false }
                    
                    _ = provider.loadObject(ofClass: URL.self) { object, error in
                        if let url = object {
                            DispatchQueue.main.async {
                                importedFile = url
                            }
                        }
                    }
                    
                    return true
                }
            
            if let file = importedFile {
                Text("Selected file: \(file.lastPathComponent)")
                    .padding()
            }
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                Button("Import") {
                    if let file = importedFile {
                        do {
                            let data = try Data(contentsOf: file)
                            appState.importPostmanCollection(from: data)
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Error reading file: \(error)")
                        }
                    }
                }
                .disabled(importedFile == nil)
            }
            .padding()
        }
        .padding()
    }
}

struct LoadProjectView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var projectFile: URL?
    
    var body: some View {
        VStack {
            Text("Load Project")
                .font(.headline)
                .padding()
            
            Text("Drag and drop your project file here or click to select")
                .frame(width: 400, height: 200)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    guard let provider = providers.first else { return false }
                    
                    _ = provider.loadObject(ofClass: URL.self) { object, error in
                        if let url = object {
                            DispatchQueue.main.async {
                                projectFile = url
                            }
                        }
                    }
                    
                    return true
                }
            
            if let file = projectFile {
                Text("Selected file: \(file.lastPathComponent)")
                    .padding()
            }
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                Button("Load") {
                    if let file = projectFile {
                        do {
                            let data = try Data(contentsOf: file)
                            appState.loadProject(from: data)
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Error reading file: \(error)")
                        }
                    }
                }
                .disabled(projectFile == nil)
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - Import/Export Utilities
class PostmanImporter {
    func importFromData(_ data: Data) -> [RequestGroup]? {
        // Implementation for parsing Postman export format
        print("Importing Postman collection...")
        // For now, return some sample data
        let sampleRequest = Request(
            name: "Imported Request",
            method: "GET",
            url: "https://jsonplaceholder.typicode.com/posts",
            headers: [Header(key: "Content-Type", value: "application/json")],
            body: ""
        )
        
        let sampleGroup = RequestGroup(
            name: "Imported Group",
            requests: [sampleRequest]
        )
        
        return [sampleGroup]
    }
}

class ProjectExporter {
    let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func exportProject() {
        // Implementation for exporting project to file
        print("Exporting project...")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let projectData = ProjectData(
                groups: appState.groups,
                environments: appState.environments
            )
            
            let _ = try encoder.encode(projectData)
            
            // In a real app, you would show a save panel here
            print("Project data encoded successfully")
        } catch {
            print("Error encoding project: \(error)")
        }
    }
}

class ProjectLoader {
    func loadProject(from data: Data) -> (groups: [RequestGroup], environments: [AppEnvironment])? {
        // Implementation for loading project from file
        print("Loading project...")
        
        let decoder = JSONDecoder()
        
        do {
            let projectData = try decoder.decode(ProjectData.self, from: data)
            return (projectData.groups, projectData.environments)
        } catch {
            print("Error decoding project: \(error)")
            return nil
        }
    }
}

struct ProjectData: Codable {
    let groups: [RequestGroup]
    let environments: [AppEnvironment]
}
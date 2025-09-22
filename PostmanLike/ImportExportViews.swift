
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
    @State private var isFilePickerPresented = false

    var body: some View {
        VStack {
            Text("Import Postman Collection")
                .font(.headline)
                .padding()

            Button("Select Postman Collection File") {
                isFilePickerPresented = true
            }
            .padding()
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            do {
                let selectedFile: URL = try result.get().first!
                let data = try Data(contentsOf: selectedFile)
                appState.importPostmanCollection(from: data)
                presentationMode.wrappedValue.dismiss()
            } catch {
                // Handle error
                print("Error selecting or reading file: \(error)")
            }
        }
    }
}

struct ExportProjectView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var isFolderPickerPresented = false

    var body: some View {
        VStack {
            Text("Export Project")
                .font(.headline)
                .padding()

            Button("Select a Folder to Export") {
                isFolderPickerPresented = true
            }
            .padding()
        }
        .fileExporter(
            isPresented: $isFolderPickerPresented,
            document: ProjectDocument(appState: appState),
            contentType: .json,
            defaultFilename: "PostmanLikeProject"
        ) { result in
            switch result {
            case .success(let url):
                print("Project exported to \(url)")
            case .failure(let error):
                print("Error exporting project: \(error)")
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct SaveProjectView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var isFileSaverPresented = true

    var body: some View {
        VStack {
            Text("Save Project")
                .font(.headline)
                .padding()

            Button("Select Where to Save the Project") {
                isFileSaverPresented = true
            }
            .padding()
        }
        .fileExporter(
            isPresented: $isFileSaverPresented,
            document: ProjectDocument(appState: appState),
            contentType: .json,
            defaultFilename: "filename"
        ) { result in
            switch result {
            case .success(let url):
                print("Project saved to \(url)")
            case .failure(let error):
                print("Error saving project: \(error)")
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct LoadProjectView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var isFilePickerPresented = false

    var body: some View {
        VStack {
            Text("Load Project")
                .font(.headline)
                .padding()

            Button("Select Project File to Load") {
                isFilePickerPresented = true
            }
            .padding()
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            do {
                let selectedFile: URL = try result.get().first!
                let data = try Data(contentsOf: selectedFile)
                appState.loadProject(from: data)
                presentationMode.wrappedValue.dismiss()
            } catch {
                // Handle error
                print("Error selecting or reading file: \(error)")
            }
        }
    }
}

struct ProjectDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }
    
    init(configuration: ReadConfiguration) throws {
        fatalError("init(configuration:) has not been implemented")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(appState.projectData)
        return FileWrapper(regularFileWithContents: data)
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


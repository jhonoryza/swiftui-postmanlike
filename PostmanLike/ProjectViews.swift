//
//  ProjectViews.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct SaveProjectView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool

    var body: some View {
        VStack {}
        .fileExporter(
            isPresented: $isPresented,
            document: ProjectDocument(appState: appState),
            contentType: .json,
            defaultFilename: "project.json"
        ) { result in
            switch result {
            case .success(let url):
                print("Project saved to \(url)")
            case .failure(let error):
                print("Error saving project: \(error)")
            }
        }
    }
}

struct LoadProjectView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool

    var body: some View {
        VStack {}
        .fileImporter(
            isPresented: $isPresented,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            do {
                let selectedFile: URL = try result.get().first!
                let data = try Data(contentsOf: selectedFile)
                appState.loadProject(from: data)
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
        if let data = configuration.file.regularFileContents {
            let projectData = try JSONDecoder().decode(ProjectData.self, from: data)
            self.appState = AppState()
            self.appState.groups = projectData.groups
            self.appState.environments = projectData.environments
        } else {
            fatalError("Cannot read file")
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(appState.projectData)
        return FileWrapper(regularFileWithContents: data)
    }
}

class ProjectLoader {
    func loadProject(from data: Data) -> (groups: [RequestGroup], environments: [AppEnvironment])? {
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


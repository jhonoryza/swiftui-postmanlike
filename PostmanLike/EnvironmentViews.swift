//
//  EnvironmentViews.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Postman Environment

struct PostmanEnvironment: Codable {
    let id: UUID
    let name: String
    var values: [PostmanValue]
    let _postman_variable_scope: String
    let _postman_exported_at: String
    let _postman_exported_using: String
}

struct PostmanValue: Codable {
    let key: String
    let value: String
    let enabled: Bool
}

struct ExportEnvironmentsView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool

    var body: some View {
        VStack {}
        .fileExporter(
            isPresented: $isPresented,
            document: EnvironmentDocument(appState: appState),
            contentType: .json,
            defaultFilename: "environments.json"
        ) { result in
            switch result {
            case .success(let url):
                print("Environments exported to \(url)")
            case .failure(let error):
                print("Error exporting environments: \(error)")
            }
        }
    }
}

struct ImportEnvironmentsView: View {
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
                appState.importEnvironments(from: data)
            } catch {
                // Handle error
                print("Error selecting or reading file: \(error)")
            }
        }
    }
}

struct EnvironmentDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            let decoder = JSONDecoder()
            let postmanEnvironment = try decoder.decode(PostmanEnvironment.self, from: data)
            self.appState = AppState()
            self.appState.environments = [postmanEnvironment.toAppEnvironment()]
        } else {
            fatalError("Cannot read file")
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(toPostmanEnvironment())
        return FileWrapper(regularFileWithContents: data)
    }
    
    private func toPostmanEnvironment() -> PostmanEnvironment {
        let values = appState.environments.flatMap { env in
            env.variables.map { key, value in
                PostmanValue(key: key, value: value, enabled: true)
            }
        }
        
        return PostmanEnvironment(
            id: UUID(),
            name: "PostmanLike Environments",
            values: values,
            _postman_variable_scope: "environment",
            _postman_exported_at: "",
            _postman_exported_using: "PostmanLike"
        )
    }
}

extension PostmanEnvironment {
    func toAppEnvironment() -> AppEnvironment {
        let variables = values.reduce(into: [String: String]()) { result, value in
            result[value.key] = value.value
        }
        return AppEnvironment(name: name, variables: variables)
    }
}

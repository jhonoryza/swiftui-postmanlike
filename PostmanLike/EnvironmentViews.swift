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
    @State private var selectedEnvironment: AppEnvironment? = nil
    @State private var isFileExporterPresented = false

    var body: some View {
        VStack {
            Text("Select an environment to export").font(.headline).padding()
            List(appState.environments, id: \.id) { environment in
                Button(environment.name) {
                    self.selectedEnvironment = environment
                    self.isFileExporterPresented = true
                }
            }
        }
        .frame(width: 300, height: 400)
        .fileExporter(
            isPresented: $isFileExporterPresented,
            document: EnvironmentDocument(environment: selectedEnvironment),
            contentType: .json,
            defaultFilename: (selectedEnvironment?.name ?? "env") + ".json"
        ) { result in
            if case .failure(let error) = result {
                print("Error exporting environment: \(error)")
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
    
    var environment: AppEnvironment?

    init(environment: AppEnvironment?) {
        self.environment = environment
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            let decoder = JSONDecoder()
            let postmanEnvironment = try decoder.decode(PostmanEnvironment.self, from: data)
            self.environment = postmanEnvironment.toAppEnvironment()
        } else {
            fatalError("Cannot read file")
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let environment = environment else {
            throw CocoaError(.fileWriteUnknown)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(toPostmanEnvironment(environment))
        return FileWrapper(regularFileWithContents: data)
    }
    
    private func toPostmanEnvironment(_ environment: AppEnvironment) -> PostmanEnvironment {
        let values = environment.variables.map { key, value in
            PostmanValue(key: key, value: value, enabled: true)
        }
        
        return PostmanEnvironment(
            id: UUID(),
            name: environment.name,
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

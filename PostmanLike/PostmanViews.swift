//
//  PostmanViews.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Postman Collection

struct PostmanCollection: Codable {
    let info: PostmanInfo
    var item: [PostmanItem]
}

struct PostmanInfo: Codable {
    let name: String
    let schema: String
}

struct PostmanItem: Codable {
    let name: String
    let item: [PostmanItem]?
    let request: PostmanRequest?
}

struct PostmanRequest: Codable {
    let method: String
    let header: [PostmanHeader]
    let body: PostmanBody?
    let url: PostmanURL
}

struct PostmanHeader: Codable {
    let key: String
    let value: String
}

struct PostmanBody: Codable {
    let mode: String
    let raw: String?
}

struct PostmanURL: Codable {
    let raw: String
    let host: [String]?
    let path: [String]?
}

struct ImportPostmanView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool

    var body: some View {
        VStack {}
        .fileImporter(
            isPresented: $isPresented,
            allowedContentTypes: [.json, .fileURL],
            allowsMultipleSelection: false
        ) { result in
            do {
                let selectedFile: URL = try result.get().first!
                let data = try Data(contentsOf: selectedFile)
                appState.importPostmanCollection(from: data)
            } catch {
                // Handle error
                print("Error selecting or reading file: \(error)")
            }
        }
    }
}

struct ExportPostmanView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool

    var body: some View {
        VStack {}
        .fileExporter(
            isPresented: $isPresented,
            document: PostmanCollectionDocument(appState: appState),
            contentType: .json,
            defaultFilename: "export.postman_collection.json"
        ) { result in
            switch result {
            case .success(let url):
                print("Project exported to \(url)")
            case .failure(let error):
                print("Error exporting project: \(error)")
            }
        }
    }
}

struct PostmanCollectionDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            let importer = PostmanImporter()
            if let projectData = importer.importFromData(data) {
                self.appState = AppState()
                self.appState.groups = projectData.groups
                self.appState.environments = projectData.environments
            } else {
                throw CocoaError(.fileReadCorruptFile)
            }
        } else {
            fatalError("Cannot read file")
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let postmanCollection = toPostmanCollection()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(postmanCollection)
        return FileWrapper(regularFileWithContents: data)
    }
    
    private func toPostmanCollection() -> PostmanCollection {
        let info = PostmanInfo(name: "PostmanLike Export", schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json")
        let items = appState.groups.map { group -> PostmanItem in
            let requests = group.requests.map { request -> PostmanItem in
                let url = PostmanURL(raw: request.url, host: nil, path: nil)
                let headers = request.headers.map { header in
                    return PostmanHeader(key: header.key, value: header.value)
                }
                let body = PostmanBody(mode: "raw", raw: request.body)
                let postmanRequest = PostmanRequest(method: request.method, header: headers, body: body, url: url)
                return PostmanItem(name: request.name, item: nil, request: postmanRequest)
            }
            return PostmanItem(name: group.name, item: requests, request: nil)
        }
        return PostmanCollection(info: info, item: items)
    }
}

class PostmanImporter {
    func importFromData(_ data: Data) -> (groups: [RequestGroup], environments: [AppEnvironment])? {
        let decoder = JSONDecoder()
        do {
            let postmanCollection = try decoder.decode(PostmanCollection.self, from: data)
            let groups = postmanCollection.item.compactMap { (item) -> RequestGroup? in
                return itemToRequestGroup(item)
            }
            return (groups, []) // Environments are not handled in Postman collections
        } catch {
            print("Error decoding project: \(error)")
            return nil
        }
    }
    
    private func itemToRequestGroup(_ item: PostmanItem) -> RequestGroup? {
        if let requests = item.item {
            let mappedRequests = requests.compactMap { item -> Request? in
                guard let postmanRequest = item.request else { return nil }
                return Request(
                    name: item.name,
                    method: postmanRequest.method,
                    url: postmanRequest.url.raw,
                    headers: postmanRequest.header.map { Header(key: $0.key, value: $0.value) },
                    body: postmanRequest.body?.raw ?? ""
                )
            }
            return RequestGroup(name: item.name, requests: mappedRequests)
        } else {
            return nil
        }
    }
}

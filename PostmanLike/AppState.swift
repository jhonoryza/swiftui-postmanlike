//
//  AppState.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var environments: [AppEnvironment] = []
    @Published var groups: [RequestCollectionGroup] = []
    @Published var collections: [RequestCollection] = []
    @Published var selectedRequest: Request?
    @Published var response: ResponseData?
    @Published var currentEnvironment: AppEnvironment?
    
    @Published var showImportPostman = false
    @Published var showLoadProject = false
    @Published var isRequesting = false
    
    init() {
        // Load sample data for demonstration
        let sampleEnv = AppEnvironment(name: "local", variables: ["baseUrl": "https://api-blog.labkita.my.id"])
        environments = [sampleEnv]
        currentEnvironment = sampleEnv
        
        let sampleRequest = Request(
            name: "Get Users",
            url: "{{baseUrl}}/api/posts",
            method: "GET",
            headers: [
                Header(key: "Content-Type", value: "application/json"),
                Header(key: "Accept", value: "application/json"),
            ]
        )
        
        let sampleCollection = RequestCollection(
            name: "Sample Collection",
            requests: [sampleRequest]
        )
        
        collections = [sampleCollection]
        selectedRequest = sampleRequest
    }
    
    func addNewCollection() {
        let newCollection = RequestCollection(name: "New Collection")
        collections.append(newCollection)
    }
    
    func addNewGroup() {
        let newGroup = RequestCollectionGroup(name: "New Group")
        groups.append(newGroup)
    }
    
    func exportProject() {
        // Implementation for exporting project
        let exporter = ProjectExporter(appState: self)
        exporter.exportProject()
    }
    
    func importPostmanCollection(from data: Data) {
        // Implementation for importing Postman collection
        let importer = PostmanImporter()
        if let importedCollections = importer.importFromData(data) {
            self.collections.append(contentsOf: importedCollections)
        }
    }
    
    func loadProject(from data: Data) {
        // Implementation for loading project
        let projectLoader = ProjectLoader()
        if let projectData = projectLoader.loadProject(from: data) {
            self.collections = projectData.collections
            self.groups = projectData.groups
            self.environments = projectData.environments
        }
    }
    
    func deleteCollection(_ collection: RequestCollection) {
        collections.removeAll { $0.id == collection.id }
        
        // Also remove from any group
        for i in groups.indices {
            groups[i].collections.removeAll { $0.id == collection.id }
        }
    }
    
    func deleteGroup(_ group: RequestCollectionGroup) {
        groups.removeAll { $0.id == group.id }
    }
}

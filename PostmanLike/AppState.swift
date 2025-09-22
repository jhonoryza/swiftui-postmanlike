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
    @Published var groups: [RequestGroup] = []
    @Published var selectedRequest: Request?
    @Published var response: ResponseData?
    @Published var currentEnvironment: AppEnvironment?
    
    @Published var showImportPostman = false
    @Published var showLoadProject = false
    
    init() {
        // Load sample data for demonstration
        let sampleEnv = AppEnvironment(name: "local", variables: ["baseUrl": "https://api-blog.labkita.my.id"])
        environments = [sampleEnv]
        currentEnvironment = sampleEnv
        
        let sampleRequest = Request(
            name: "Get Users",
            method: "GET",
            url: "{{baseUrl}}/api/posts",
            headers: [
                Header(key: "Content-Type", value: "application/json"),
                Header(key: "Accept", value: "application/json"),
            ],
            body: ""
        )
        
        let sampleGroup = RequestGroup(
            name: "Sample Group",
            requests: [sampleRequest]
        )
        
        groups = [sampleGroup]
        selectedRequest = sampleRequest
    }
    
    func addNewRequest(to group: RequestGroup) {
        let newRequest = Request(name: "New Request", method: "GET", url: "", headers: [], body: "")
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].requests.append(newRequest)
        }
    }
    
    func addNewGroup(name: String) {
        let newGroup = RequestGroup(name: name, requests: [])
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
        if let importedGroups = importer.importFromData(data) {
            self.groups.append(contentsOf: importedGroups)
        }
    }
    
    func loadProject(from data: Data) {
        // Implementation for loading project
        let projectLoader = ProjectLoader()
        if let projectData = projectLoader.loadProject(from: data) {
            self.groups = projectData.groups
            self.environments = projectData.environments
        }
    }
    
    func deleteRequest(_ request: Request) {
        for i in groups.indices {
            groups[i].requests.removeAll { $0.id == request.id }
        }
    }
    
    func deleteGroup(_ group: RequestGroup) {
        groups.removeAll { $0.id == group.id }
    }
    
    func updateRequest(_ request: Request) {
        for i in groups.indices {
            if let reqIndex = groups[i].requests.firstIndex(where: { $0.id == request.id }) {
                groups[i].requests[reqIndex] = request
            }
        }
    }
}
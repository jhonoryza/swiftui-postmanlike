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
    @Published var showExportPostman = false
    @Published var showSaveProject = false
    @Published var showImportEnvironments = false
    @Published var showExportEnvironments = false
    
    var projectData: ProjectData {
        ProjectData(groups: groups, environments: environments)
    }
    
    init() {
        // Load sample data for demonstration
        let sampleEnv = AppEnvironment(name: "local", variables: ["baseUrl": "https://api-blog.labkita.my.id"])
        environments = [sampleEnv]
        currentEnvironment = sampleEnv
        
        let sampleRequest = Request(
            name: "posts index",
            method: "GET",
            url: "{{baseUrl}}/api/posts",
            headers: [
                Header(key: "Content-Type", value: "application/json"),
                Header(key: "Accept", value: "application/json"),
            ],
            body: ""
        )
        
        let sampleGroup = RequestGroup(
            name: "personal",
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
    
    func importPostmanCollection(from data: Data) {
        let importer = PostmanImporter()
        if let projectData = importer.importFromData(data) {
            self.groups.append(contentsOf: projectData.groups)
            
            for environment in projectData.environments {
                if let index = self.environments.firstIndex(where: { $0.name == environment.name }) {
                    self.environments[index] = environment
                } else {
                    self.environments.append(environment)
                }
            }
        }
    }
    
    func importEnvironments(from data: Data) {
        let decoder = JSONDecoder()
        do {
            let postmanEnvironment = try decoder.decode(PostmanEnvironment.self, from: data)
            let appEnvironment = postmanEnvironment.toAppEnvironment()
            if let index = self.environments.firstIndex(where: { $0.name == appEnvironment.name }) {
                self.environments[index] = appEnvironment
            } else {
                self.environments.append(appEnvironment)
            }
        } catch {
            print("Error decoding environments: \(error)")
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

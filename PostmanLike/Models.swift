//
//  Models.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import Foundation

// MARK: - Data Models
struct AppEnvironment: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var variables: [String: String]
    
    init(id: UUID = UUID(), name: String, variables: [String: String] = ["baseUrl": "https://api.example.com"]) {
        self.id = id
        self.name = name
        self.variables = variables
    }
}

struct RequestCollection: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var requests: [Request]
    var groupId: UUID?
    
    init(id: UUID = UUID(), name: String, requests: [Request] = [], groupId: UUID? = nil) {
        self.id = id
        self.name = name
        self.requests = requests
        self.groupId = groupId
    }
}

struct RequestCollectionGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var collections: [RequestCollection]
    
    init(id: UUID = UUID(), name: String, collections: [RequestCollection] = []) {
        self.id = id
        self.name = name
        self.collections = collections
    }
}

struct Request: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var url: String
    var method: String
    var headers: [Header]
    var body: String
    var bodyType: BodyType
    var formData: [FormDataItem]

    init(id: UUID = UUID(), name: String, url: String, method: String = "GET", headers: [Header] = [], body: String = "", bodyType: BodyType = .json, formData: [FormDataItem] = []) {
        self.id = id
        self.name = name
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.bodyType = bodyType
        self.formData = formData
    }
}

struct Header: Identifiable, Codable, Hashable {
    let id: UUID
    var key: String
    var value: String
    var isEnabled: Bool
    
    init(id: UUID = UUID(), key: String, value: String, isEnabled: Bool = true) {
        self.id = id
        self.key = key
        self.value = value
        self.isEnabled = isEnabled
    }
}

enum BodyType: String, CaseIterable, Codable {
    case json = "JSON"
    case formData = "Form Data"
}

struct ResponseData: Identifiable, Codable {
    let id: UUID
    var statusCode: Int?
    var headers: [Header]
    var body: String
    var error: String?
    var time: TimeInterval?
    var size: Int?
    
    init(id: UUID = UUID(), statusCode: Int? = nil, headers: [Header] = [], body: String = "", error: String? = nil, time: TimeInterval? = nil, size: Int? = nil) {
        self.id = id
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.error = error
        self.time = time
        self.size = size
    }
}

import Foundation

struct RequestGroup: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var requests: [Request]
}

struct Request: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var method: String
    var url: String
    var headers: [Header]
    var body: String
    var bodyType: BodyType = .json
    var formData: [FormDataItem] = []
}

struct Header: Identifiable, Codable, Hashable {
    var id = UUID()
    var key: String
    var value: String
    var isEnabled: Bool = true
}

enum BodyType: String, CaseIterable, Codable, Hashable {
    case json = "JSON"
    case formData = "Form Data"
}

struct ResponseData: Codable, Hashable {
    var id = UUID()
    var statusCode: Int? = nil
    var headers: [Header] = []
    var body: String = ""
    var error: String? = nil
    var time: TimeInterval? = nil
    var size: Int? = nil
}

struct AppEnvironment: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var variables: [String: String] = [:]
}

struct FormDataItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var enabled = true
    var key = ""
    var value = ""
}
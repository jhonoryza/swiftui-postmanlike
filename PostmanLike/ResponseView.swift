//
//  ResponseView.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI

struct ResponseView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = "Raw"
    
    var body: some View {
        VStack {
            if let response = appState.response {
                HStack {
                    if let statusCode = response.statusCode {
                        Text("Status: \(statusCode)")
                            .foregroundColor(statusCode >= 200 && statusCode < 300 ? .green : .red)
                    }
                    Spacer()
                    if let time = response.time {
                        Text(String(format: "Time: %.2f ms", time * 1000))
                    }
                    Spacer()
                    if let size = response.size {
                        Text("Size: \(size) B")
                    }
                }
                .padding()
                                
                Picker("", selection: $selectedTab) {
                    Text("Json").tag("Json")
                    Text("Raw").tag("Raw")
                    Text("Headers").tag("Headers")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedTab == "Json" {
                    if let data = (response.body.prettyPrintedJSON ?? response.body).data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) {
                        let rootNode = parseJSON(json, key: "root")

                        JSONView(root: rootNode)
                            .padding()
                    } else {
                        Text("Invalid JSON")
                            .foregroundStyle(.red)
                    }
                } else if selectedTab == "Raw" {
                    TextEditor(text: .constant(response.body.prettyPrintedJSON ?? response.body))
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding()
                } else {
                    List(response.headers) { header in
                        HStack {
                            Text(header.key)
                                .textSelection(.enabled)
                                .fontWeight(.bold)
                            Spacer()
                            Text(header.value)
                                .textSelection(.enabled)
                        }
                    }
                }
            } else {
                Text("No response yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
    }
}

extension String {
    var prettyPrintedJSON: String? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let prettyData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

struct JSONNode: Identifiable {
    let id = UUID()
    let key: String
    let value: String?
    var children: [JSONNode]?
}

func parseJSON(_ json: Any, key: String = "root") -> JSONNode {
    if let dict = json as? [String: Any] {
        return JSONNode(
            key: key,
            value: nil,
            children: dict.map { parseJSON($0.value, key: $0.key) }
        )
    } else if let array = json as? [Any] {
        return JSONNode(
            key: key,
            value: nil,
            children: array.enumerated().map { parseJSON($0.element, key: "[\($0.offset)]") }
        )
    } else {
        return JSONNode(key: key, value: "\(json)", children: nil)
    }
}


struct JSONView: View {
    let root: JSONNode

    var body: some View {
        List {
            OutlineGroup([root], children: \.children) { node in
                HStack {
                    Text(node.key)
                        .textSelection(.enabled)
                        .bold()
                    if let value = node.value {
                        Spacer()
                        Text(value)
                            .textSelection(.enabled)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.system(.body, design: .monospaced))
            }
        }
    }
}

//
//  ResponseView.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI

struct ResponseView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = "Body"
    
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
                    Text("Body").tag("Body")
                    Text("Headers").tag("Headers")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedTab == "Body" {
                    ScrollView {
                        Text(response.body.prettyPrintedJSON ?? response.body)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    List(response.headers) { header in
                        HStack {
                            Text(header.key)
                                .fontWeight(.bold)
                            Spacer()
                            Text(header.value)
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

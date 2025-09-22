//
//  RequestView.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI

struct RequestView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = "Headers"
    
    @State private var url: String = ""
    @State private var method: String = "GET"
    @State private var headers: [Header] = []
    @State private var bodyText: String = ""
    @State private var bodyType: BodyType = .json
    @State private var formData: [FormDataItem] = []

    var body: some View {
        ZStack {
            VStack {
                if appState.selectedRequest != nil {
                    // URL and Method
                    HStack {
                        Picker("Method", selection: $method) {
                            Text("GET").tag("GET")
                            Text("POST").tag("POST")
                            Text("PUT").tag("PUT")
                            Text("DELETE").tag("DELETE")
                            Text("PATCH").tag("PATCH")
                        }
                        .frame(width: 120)
                        
                        TextField("URL", text: $url)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        if(appState.isRequesting) {
                            Button("Cancel") {
                                cancelRequest()
                            }
                        } else {
                            Button("Send") {
                                sendRequest()
                            }
                        }
                    }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

                    ProgressView(value: appState.isRequesting ? 1.0 : 0)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

                    // Headers/Body selector
                    Picker("", selection: $selectedTab) {
                        Text("Headers").tag("Headers")
                        Text("Body").tag("Body")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Headers or Body view based on selection
                    if selectedTab == "Headers" {
                        HeadersView(headers: $headers)
                    } else {
                        BodyView(bodyText: $bodyText, bodyType: $bodyType, formData: $formData)
                    }
                    
                    Spacer()
                } else {
                    Text("Select a request to begin")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onAppear {
                loadRequestData()
            }
            .onChange(of: appState.selectedRequest) { _ in
                loadRequestData()
            }
            .onChange(of: url) { _ in saveData() }
            .onChange(of: method) { _ in saveData() }
            .onChange(of: headers) { _ in saveData() }
            .onChange(of: bodyText) { _ in saveData() }
            .onChange(of: bodyType) { _ in saveData() }
            .onChange(of: formData) { _ in saveData() }
        }
    }
    
    private func loadRequestData() {
        if let request = appState.selectedRequest {
            url = request.url
            method = request.method
            headers = request.headers
            bodyText = request.body
            bodyType = request.bodyType
            formData = request.formData
        }
    }
    
    private func saveData() {
        guard let selectedRequest = appState.selectedRequest, let index = appState.collections.firstIndex(where: { $0.requests.contains(where: { $0.id == selectedRequest.id }) }) else { return }
        guard let reqIndex = appState.collections[index].requests.firstIndex(where: { $0.id == selectedRequest.id }) else { return }
        
        appState.collections[index].requests[reqIndex].url = url
        appState.collections[index].requests[reqIndex].method = method
        appState.collections[index].requests[reqIndex].headers = headers
        appState.collections[index].requests[reqIndex].body = bodyText
        appState.collections[index].requests[reqIndex].bodyType = bodyType
        appState.collections[index].requests[reqIndex].formData = formData
    }
    
    private func cancelRequest() {
        appState.isRequesting = false;
    }
    
    private func sendRequest() {
        appState.isRequesting = true
        let startTime = Date()
        
        let finalURL = replaceEnvironmentVariables(in: url)
        guard let url = URL(string: finalURL) else {
            appState.response = ResponseData(error: "Invalid URL")
            appState.isRequesting = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        headers.forEach {
            if $0.isEnabled {
                request.setValue(replaceEnvironmentVariables(in: $0.value), forHTTPHeaderField: $0.key)
            }
        }
        
        if method != "GET" {
            switch bodyType {
            case .json:
                if !bodyText.isEmpty {
                    request.httpBody = replaceEnvironmentVariables(in: bodyText).data(using: .utf8)
                }
            case .formData:
                let boundary = "Boundary-\(UUID().uuidString)"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                var body = Data()
                for item in formData {
                    if item.enabled {
                        body.append("--\(boundary)\r\n".data(using: .utf8)!)
                        body.append("Content-Disposition: form-data; name=\"\(item.key)\"\r\n\r\n".data(using: .utf8)!)
                        body.append("\(item.value)\r\n".data(using: .utf8)!)
                    }
                }
                body.append("--\(boundary)--\r\n".data(using: .utf8)!)
                request.httpBody = body
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let time = Date().timeIntervalSince(startTime)
            DispatchQueue.main.async {
                appState.isRequesting = false
                if let error = error {
                    appState.response = ResponseData(error: error.localizedDescription, time: time)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    appState.response = ResponseData(error: "Invalid response from server", time: time)
                    return
                }
                
                var responseHeaders: [Header] = []
                for (key, value) in httpResponse.allHeaderFields {
                    responseHeaders.append(Header(key: "\(key)", value: "\(value)"))
                }
                
                let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                let size = data?.count ?? 0
                
                appState.response = ResponseData(
                    statusCode: httpResponse.statusCode,
                    headers: responseHeaders,
                    body: bodyString,
                    time: time,
                    size: size
                )
            }
        }
        
        task.resume()
    }
    
    private func replaceEnvironmentVariables(in string: String) -> String {
        guard let environment = appState.currentEnvironment else { return string }
        var result = string
        for (key, value) in environment.variables {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return result
    }
}

struct HeadersView: View {
    @Binding var headers: [Header]

    var body: some View {
        List {
            ForEach($headers) { $header in
                HStack {
                    Toggle("", isOn: $header.isEnabled)
                    TextField("Key", text: $header.key)
                    TextField("Value", text: $header.value)
                }
            }
            .onDelete(perform: deleteHeader)
            
            Button(action: addHeader) {
                Label("Add Header", systemImage: "plus")
            }
        }
    }

    private func addHeader() {
        headers.append(Header(key: "", value: ""))
    }

    private func deleteHeader(at offsets: IndexSet) {
        headers.remove(atOffsets: offsets)
    }
}

struct BodyView: View {
    @Binding var bodyText: String
    @Binding var bodyType: BodyType
    @Binding var formData: [FormDataItem]

    var body: some View {
        VStack {
            Picker("Body Type", selection: $bodyType) {
                ForEach(BodyType.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            switch bodyType {
            case .json:
                TextEditor(text: $bodyText)
                    .font(.system(.body, design: .monospaced))
                    .border(Color.gray, width: 1)
                    .padding()
            case .formData:
                FormDataView(formData: $formData)
            }
        }
    }
}

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
    
    @State private var isRequesting = false
    @State private var currentTask: URLSessionDataTask?

    private var selectedRequest: Binding<Request> {
        Binding<Request>(
            get: { appState.selectedRequest! },
            set: { appState.selectedRequest = $0 }
        )
    }

    var body: some View {
        ZStack {
            if appState.selectedRequest != nil {
                VStack {
                    // URL and Method
                    HStack {
                        Picker("Method", selection: selectedRequest.method) {
                            Text("GET").tag("GET")
                            Text("POST").tag("POST")
                            Text("PUT").tag("PUT")
                            Text("DELETE").tag("DELETE")
                            Text("PATCH").tag("PATCH")
                        }
                        .frame(width: 120)
                        
                        TextField("URL", text: selectedRequest.url)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if isRequesting {
                            Button("Cancel") {
                                cancelRequest()
                            }
                        } else {
                            Button("Send") {
                                sendRequest()
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    ProgressView(value: isRequesting ? 1.0 : 0)
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
                        HeadersView(headers: selectedRequest.headers)
                    } else {
                        BodyView(bodyText: selectedRequest.body, bodyType: selectedRequest.bodyType, formData: selectedRequest.formData)
                    }
                    
                    Spacer()
                }
                .focusable()
                .onReceive(NotificationCenter.default.publisher(for: .save)) { _ in
                    saveData()
                }
            } else {
                Text("Select a request to begin")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func saveData() {
        if let request = appState.selectedRequest {
            appState.updateRequest(request)
        }
    }
    
    private func cancelRequest() {
        isRequesting = false
        currentTask?.cancel()
    }
    
    private func sendRequest() {
        guard let request = appState.selectedRequest else { return }
        isRequesting = true
        let startTime = Date()
        
        let finalURL = replaceEnvironmentVariables(in: request.url)
        guard let url = URL(string: finalURL) else {
            appState.response = ResponseData(error: "Invalid URL")
            isRequesting = false
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        
        request.headers.forEach {
            if $0.isEnabled {
                urlRequest.setValue(replaceEnvironmentVariables(in: $0.value), forHTTPHeaderField: $0.key)
            }
        }
        
        if request.method != "GET" {
            switch request.bodyType {
            case .json:
                if !request.body.isEmpty {
                    urlRequest.httpBody = replaceEnvironmentVariables(in: request.body).data(using: .utf8)
                }
            case .formData:
                let boundary = "Boundary-\(UUID().uuidString)"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                var body = Data()
                for item in request.formData {
                    if item.enabled {
                        body.append("--\(boundary)\r\n".data(using: .utf8)!)
                        body.append("Content-Disposition: form-data; name=\"\(item.key)\"\r\n\r\n".data(using: .utf8)!)
                        body.append("\(item.value)\r\n".data(using: .utf8)!)
                    }
                }
                body.append("--\(boundary)--\r\n".data(using: .utf8)!)
                urlRequest.httpBody = body
            }
        }
        
        currentTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            let time = Date().timeIntervalSince(startTime)
            DispatchQueue.main.async {
                isRequesting = false
                if let error = error {
                    if (error as NSError).code == NSURLErrorCancelled {
                        return // Request was cancelled
                    }
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
        
        currentTask?.resume()
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

struct FormDataView: View {
    @Binding var formData: [FormDataItem]
    
    var body: some View {
        List {
            ForEach($formData) { $item in
                HStack {
                    Toggle("", isOn: $item.enabled)
                    TextField("Key", text: $item.key)
                    TextField("Value", text: $item.value)
                }
            }
            .onDelete(perform: deleteItem)
            
            Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            }
        }
    }
    
    private func addItem() {
        formData.append(FormDataItem())
    }
    
    private func deleteItem(at offsets: IndexSet) {
        formData.remove(atOffsets: offsets)
    }
}

extension Notification.Name {
    static let save = Notification.Name("save")
}

//
//  SupportingViews.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: RequestCollection
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List(collection.requests) { request in
            Button(action: {
                appState.selectedRequest = request
            }) {
                HStack {
                    Text(request.method)
                        .font(.system(.caption, design: .monospaced))
                        .padding(4)
                        .background(methodColor(request.method))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    Text(request.name)
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle(collection.name)
    }
    
    func methodColor(_ method: String) -> Color {
        switch method.uppercased() {
        case "GET": return .green
        case "POST": return .blue
        case "PUT": return .orange
        case "DELETE": return .red
        case "PATCH": return .purple
        default: return .gray
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

struct FormDataItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var enabled = true
    var key = ""
    var value = ""
}
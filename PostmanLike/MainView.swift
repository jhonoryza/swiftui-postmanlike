
//
//  MainView.swift
//  PostmanLike
//
//  Created by fajar on 22/9/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedView = "Request"

    var body: some View {
        VStack {
            Picker("", selection: $selectedView) {
                Text("Request").tag("Request")
                Text("Environments").tag("Environments")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedView == "Request" {
                RequestView()
            } else {
                EnvironmentView()
            }
        }
    }
}


import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingNewGroup = false
    @State private var newGroupName = ""

    var body: some View {
        VStack {
            List {
                EnvironmentListView()
                GroupListView()
            }
            .listStyle(SidebarListStyle())

            // MARK: New Group Button
            HStack {
                Button(action: { showingNewGroup = true }) {
                    Label("New Group", systemImage: "plus")
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
                Spacer()
            }
        }
        .sheet(isPresented: $showingNewGroup) {
            NewGroupSheet(showingNewGroup: $showingNewGroup, newGroupName: $newGroupName)
                .environmentObject(appState)
        }
    }
}

struct EnvironmentListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Section("Environments") {
            ForEach(appState.environments) { environment in
                EnvironmentRow(environment: environment)
            }
        }
    }
}

struct GroupListView: View {
    @EnvironmentObject var appState: AppState
    @State private var expandedGroups: Set<UUID> = []

    var body: some View {
        Section("Groups") {
            ForEach(appState.groups) { group in
                GroupRow(
                    group: group,
                    isExpanded: Binding(
                        get: { expandedGroups.contains(group.id) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedGroups.insert(group.id)
                            } else {
                                expandedGroups.remove(group.id)
                            }
                        }
                    )
                )
            }
        }
    }
}

struct EnvironmentRow: View {
    @EnvironmentObject var appState: AppState
    let environment: AppEnvironment

    var body: some View {
        Button(action: { appState.currentEnvironment = environment }) {
            HStack {
                Text(environment.name)
                Spacer()
                if appState.currentEnvironment?.id == environment.id {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .padding(4)
        .background(appState.currentEnvironment?.id == environment.id ? Color.accentColor.opacity(0.5) : Color.clear)
        .cornerRadius(5)
        .contextMenu {
            Button("Delete") {
                if appState.environments.count > 1 {
                    appState.environments.removeAll { $0.id == environment.id }
                    if appState.currentEnvironment?.id == environment.id {
                        appState.currentEnvironment = appState.environments.first
                    }
                }
            }
            .disabled(appState.environments.count <= 1)
        }
    }
}

struct GroupRow: View {
    @EnvironmentObject var appState: AppState
    let group: RequestGroup
    @State private var renamingGroup = false
    @State private var newGroupName = ""
    @Binding var isExpanded: Bool

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(group.requests) { request in
                RequestRow(request: request, group: group)
            }
        } label: {
            HStack {
                if renamingGroup {
                    TextField("New Name", text: $newGroupName, onCommit: {
                        if let idx = appState.groups.firstIndex(where: { $0.id == group.id }) {
                            appState.groups[idx].name = newGroupName
                        }
                        renamingGroup = false
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(group.name)
                        .font(.headline)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                renamingGroup = true
                newGroupName = group.name
            }
        }
        .contextMenu {
            Button("Add New Request") {
                appState.addNewRequest(to: group)
            }
            Button("Delete Group") {
                appState.deleteGroup(group)
            }
        }
    }
}

struct RequestRow: View {
    @EnvironmentObject var appState: AppState
    let request: Request
    let group: RequestGroup
    @State private var renaming = false
    @State private var newRequestName = ""

    var body: some View {
        HStack {
            Button(action: { appState.selectedRequest = request }) {
                HStack {
                    if renaming {
                        TextField("New Name", text: $newRequestName, onCommit: {
                            if let index = group.requests.firstIndex(where: { $0.id == request.id }) {
                                if let groupIndex = appState.groups.firstIndex(where: { $0.id == group.id }) {
                                    appState.groups[groupIndex].requests[index].name = newRequestName
                                }
                            }
                            renaming = false
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(request.name)
                    }
                    Spacer()
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Button(action: { appState.deleteRequest(request) }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(4)
        .background(appState.selectedRequest?.id == request.id ? Color.accentColor.opacity(0.5) : Color.clear)
        .cornerRadius(5)
        .onTapGesture(count: 2) {
            renaming = true
            newRequestName = request.name
        }
    }
}

struct NewGroupSheet: View {
    @EnvironmentObject var appState: AppState
    @Binding var showingNewGroup: Bool
    @Binding var newGroupName: String

    var body: some View {
        VStack {
            Text("New Group")
                .font(.headline)
                .padding()

            TextField("Group Name", text: $newGroupName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Button("Cancel") {
                    showingNewGroup = false
                    newGroupName = ""
                }

                Button("Create") {
                    if !newGroupName.isEmpty {
                        appState.addNewGroup(name: newGroupName)
                        showingNewGroup = false
                        newGroupName = ""
                    }
                }
                .disabled(newGroupName.isEmpty)
            }
            .padding()
        }
        .padding()
        .frame(width: 300)
    }
}

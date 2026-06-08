import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var settings = AppSettings.shared
    @Binding var showingSettings: Bool

    @State private var selectedTab = "preferences"
    @State private var projectPendingDeletion: SavedProject? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    showingSettings = false
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

                Spacer()

                Picker("", selection: $selectedTab) {
                    Text("Preferences").tag("preferences")
                    Text("Projects").tag("projects")
                }
                .pickerStyle(.segmented)
                .frame(width: 180)

                Spacer()

                // Invisible spacer to balance the Back button so the title stays centered.
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .hidden()
            }
            .padding(10)

            Divider()

            if selectedTab == "preferences" {
                preferencesView
            } else {
                projectsView
            }

            Spacer(minLength: 0)
        }
    }

    private var preferencesView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Popover size")
                    .font(.callout)
                Picker("Popover size", selection: $settings.popoverSize) {
                    ForEach(PopoverSize.allCases) { size in
                        Text(size.label).tag(size)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                Text(settings.popoverSize.dimensionsLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Menu bar indicator")
                    .font(.callout)
                Picker("Menu bar indicator", selection: $settings.menuBarIndicator) {
                    ForEach(MenuBarIndicator.allCases) { indicator in
                        Text(indicator.label).tag(indicator)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                Text("Show the desktop's color as a dot before the name, as an underline beneath it, or not at all.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Markdown rendering", isOn: $settings.markdownRendering)
                    .font(.callout)
                Text("Format markdown syntax in notes (except for the active line).")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
    }

    private var projectsView: some View {
        ScrollView {
            VStack(spacing: 12) {
                let savedProjects = appState.store.projects.values.sorted {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }

                if savedProjects.isEmpty {
                    Text("No saved projects")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(savedProjects) { project in
                        HStack {
                            TextField("Project Name", text: Binding(
                                get: { project.name },
                                set: { appState.renameProject(project.id, to: $0) }
                            ))
                            .textFieldStyle(.roundedBorder)

                            Button {
                                projectPendingDeletion = project
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(12)
        }
        .alert(
            "Delete Project?",
            isPresented: Binding(
                get: { projectPendingDeletion != nil },
                set: { if !$0 { projectPendingDeletion = nil } }
            ),
            presenting: projectPendingDeletion
        ) { project in
            Button("Delete", role: .destructive) {
                appState.deleteProject(project.id)
                projectPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) {
                projectPendingDeletion = nil
            }
        } message: { project in
            Text(
                "\"\(project.name)\" will be removed from saved projects. "
                    + "Spaces using it will return to their local labels."
            )
        }
    }
}

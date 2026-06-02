import AppKit
import SwiftUI

struct SpaceDetailView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var settings = AppSettings.shared
    let spaceInfo: SpaceInfo
    @Binding var showingSettings: Bool

    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var colorTag: String? = nil
    @State private var lastEdited: Date? = nil
    @State private var saveWorkItem: DispatchWorkItem? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Desktop \(spaceInfo.index)")
                    .font(.headline)

                Spacer()

                Button {
                    saveNow()
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .help("Settings")

                Button("Quit") {
                    save()
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.caption)
            }
            .padding(10)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Project Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Name this desktop...", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { save() }
                }

                // Color tag picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Color Tag")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        ForEach(SpaceProfile.availableColors, id: \.name) { item in
                            Button {
                                colorTag = item.name
                            } label: {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(colorTag == item.name ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Notes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button {
                            settings.notesExpanded.toggle()
                        } label: {
                            Image(systemName: settings.notesExpanded
                                ? "arrow.down.right.and.arrow.up.left"
                                : "arrow.up.left.and.arrow.down.right")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                        .help(settings.notesExpanded ? "Collapse notes" : "Expand notes")
                    }
                    TextEditor(text: $notes)
                        .font(.body)
                        .frame(minHeight: 150, maxHeight: notesMaxHeight)
                        .scrollContentBackground(.hidden)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(nsColor: .controlBackgroundColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                        )

                    if let lastEdited {
                        Text(lastEdited, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            + Text(" ago")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
        }
        .background {
            if let colorTag,
               let color = SpaceProfile.availableColors.first(where: { $0.name == colorTag })?.color {
                color.opacity(0.08)
            }
        }
        .onAppear {
            let profile = appState.store.profile(for: spaceInfo.uuid)
            name = profile.name
            notes = profile.notes
            colorTag = profile.colorTag
            lastEdited = profile.lastEdited
        }
        // Debounced autosave so notes are written to disk while editing, not only
        // when the popover closes. This protects against the app quitting or being
        // killed with the popover still open.
        .onChange(of: name) { scheduleSave() }
        .onChange(of: notes) { scheduleSave() }
        // Color is a discrete tap — save immediately so the menu bar dot updates fast.
        .onChange(of: colorTag) { saveNow() }
        .onDisappear {
            saveNow()
        }
    }

    /// Notes editor ceiling: a compact fixed height normally, or ~70% of the
    /// screen height when expanded so it can fill most of the display.
    private var notesMaxHeight: CGFloat {
        guard settings.notesExpanded else { return 300 }
        let screenHeight = NSScreen.main?.visibleFrame.height ?? 900
        return max(400, screenHeight * 0.7)
    }

    /// Cancel any pending debounce and write immediately.
    private func saveNow() {
        saveWorkItem?.cancel()
        saveWorkItem = nil
        save()
    }

    /// Coalesce rapid edits into a single write ~0.6s after typing stops.
    private func scheduleSave() {
        saveWorkItem?.cancel()
        let work = DispatchWorkItem { save() }
        saveWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
    }

    private func save() {
        let profile = SpaceProfile(
            id: spaceInfo.uuid,
            name: name,
            notes: notes,
            colorTag: colorTag,
            lastEdited: Date()
        )
        appState.saveProfile(profile)
    }
}

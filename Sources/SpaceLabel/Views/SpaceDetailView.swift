import SwiftUI

struct SpaceDetailView: View {
    @EnvironmentObject var appState: AppState
    let spaceInfo: SpaceInfo

    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var colorTag: String? = nil
    @State private var lastEdited: Date? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Desktop \(spaceInfo.index)")
                    .font(.headline)

                Spacer()

                Button("Quit") {
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
                        // "None" option
                        Button {
                            colorTag = nil
                        } label: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(colorTag == nil ? Color.primary : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)

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
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $notes)
                        .font(.body)
                        .frame(minHeight: 150, maxHeight: 600)
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
        .onAppear {
            let profile = appState.store.profile(for: spaceInfo.uuid)
            name = profile.name
            notes = profile.notes
            colorTag = profile.colorTag
            lastEdited = profile.lastEdited
        }
        .onDisappear {
            save()
        }
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

import SwiftUI

struct SpaceDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let spaceInfo: SpaceInfo

    @State private var name: String = ""
    @State private var notes: String = ""

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

                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $notes)
                        .font(.body)
                        .frame(minHeight: 100, maxHeight: 160)
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
                }
            }
            .padding(12)

            Divider()

            HStack {
                Spacer()
                Button("Save") { save() }
                    .keyboardShortcut(.return)
            }
            .padding(10)
        }
        .onAppear {
            let profile = appState.store.profile(for: spaceInfo.uuid)
            name = profile.name
            notes = profile.notes
        }
    }

    private func save() {
        let profile = SpaceProfile(id: spaceInfo.uuid, name: name, notes: notes)
        appState.saveProfile(profile)
        dismiss()
    }
}

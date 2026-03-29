import SwiftUI

struct SpaceListView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSpace: SpaceInfo?

    var body: some View {
        VStack(spacing: 0) {
            if let selectedSpace {
                SpaceDetailView(
                    spaceInfo: selectedSpace,
                    onBack: { self.selectedSpace = nil }
                )
            } else {
                listContent
            }
        }
        .frame(width: 280)
    }

    private var listContent: some View {
        VStack(spacing: 0) {
            Text("SpaceNotes")
                .font(.headline)
                .padding(.vertical, 10)

            Divider()

            ScrollView {
                VStack(spacing: 2) {
                    ForEach(appState.detector.allSpaces) { space in
                        spaceRow(space)
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: 300)

            Divider()

            Button("Quit SpaceNotes") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .padding(10)
        }
    }

    private func spaceRow(_ space: SpaceInfo) -> some View {
        let profile = appState.store.profile(for: space.uuid)
        let displayName = profile.name.isEmpty ? "Desktop \(space.index)" : profile.name

        return Button {
            selectedSpace = space
        } label: {
            HStack {
                Circle()
                    .fill(space.isCurrentSpace ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)

                Text(displayName)
                    .font(.body)
                    .lineLimit(1)

                Spacer()

                if !profile.notes.isEmpty {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(space.isCurrentSpace ? Color.accentColor.opacity(0.1) : Color.clear)
        )
    }
}

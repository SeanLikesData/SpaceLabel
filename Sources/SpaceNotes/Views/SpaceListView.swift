import SwiftUI

struct SpaceListView: View {
    @EnvironmentObject var appState: AppState

    private var otherSpaces: [SpaceInfo] {
        appState.detector.allSpaces.filter { $0.uuid != appState.detector.currentSpaceUUID }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let currentSpace = appState.detector.allSpaces.first(where: { $0.uuid == appState.detector.currentSpaceUUID }) {
                SpaceDetailView(spaceInfo: currentSpace)
            } else {
                Text("No desktop detected")
                    .foregroundColor(.secondary)
                    .padding()
            }

            if !otherSpaces.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 0) {
                    Text("Switch To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    ForEach(otherSpaces) { space in
                        Button {
                            appState.detector.switchTo(space: space)
                        } label: {
                            HStack(spacing: 8) {
                                let profile = appState.store.profile(for: space.uuid)
                                if let color = profile.tagColor {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 8, height: 8)
                                } else {
                                    Circle()
                                        .fill(Color.secondary.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                                Text(profile.name.isEmpty ? "Desktop \(space.index)" : profile.name)
                                    .lineLimit(1)
                                Spacer()
                                Text("\(space.index)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .frame(width: 280)
    }
}

import SwiftUI

struct SpaceListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            if let currentSpace = appState.detector.allSpaces.first(where: { $0.uuid == appState.detector.currentSpaceUUID }) {
                SpaceDetailView(spaceInfo: currentSpace)
            } else {
                Text("No desktop detected")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .frame(width: 280)
    }
}

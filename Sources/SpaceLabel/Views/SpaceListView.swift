import SwiftUI

struct SpaceListView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var settings = AppSettings.shared
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            if showingSettings {
                SettingsView(showingSettings: $showingSettings)
            } else if let currentSpace = appState.detector.allSpaces.first(where: { $0.uuid == appState.detector.currentSpaceUUID }) {
                SpaceDetailView(spaceInfo: currentSpace, showingSettings: $showingSettings)
                    .id(currentSpace.uuid)
            } else {
                Text("No desktop detected")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .frame(
            width: settings.popoverSize.width,
            height: showingSettings || !settings.notesExpanded
                ? settings.popoverSize.height
                : nil
        )
        .onExitCommand {
            NSApp.keyWindow?.close()
        }
    }
}

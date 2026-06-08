import SwiftUI

extension Notification.Name {
    static let spaceLabelPopoverSizeDidChange = Notification.Name(
        "SpaceLabel.popoverSizeDidChange"
    )
}

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
        .onAppear {
            notifyPopoverSize()
        }
        .onChange(of: showingSettings) {
            notifyPopoverSize()
        }
        .onChange(of: settings.notesExpanded) {
            notifyPopoverSize()
        }
        .onChange(of: settings.popoverSize) {
            notifyPopoverSize()
        }
        .onExitCommand {
            NSApp.keyWindow?.close()
        }
    }

    private func notifyPopoverSize() {
        let height: CGFloat
        if showingSettings || !settings.notesExpanded {
            height = settings.popoverSize.height
        } else {
            let visibleHeight = NSScreen.main?.visibleFrame.height ?? 900
            height = max(settings.popoverSize.height, visibleHeight * 0.85)
        }

        NotificationCenter.default.post(
            name: .spaceLabelPopoverSizeDidChange,
            object: NSSize(width: settings.popoverSize.width, height: height)
        )
    }
}

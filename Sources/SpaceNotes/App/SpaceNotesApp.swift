import SwiftUI

@main
struct SpaceNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            SpaceListView()
                .environmentObject(appState)
        } label: {
            HStack(spacing: 4) {
                if let colorTag = appState.currentColorTag,
                   let color = SpaceProfile.availableColors.first(where: { $0.name == colorTag }) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 7))
                        .foregroundColor(color.color)
                }
                Text(appState.menuBarLabel)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: appState.menuBarLabel)
            }
        }
        .menuBarExtraStyle(.window)
    }
}

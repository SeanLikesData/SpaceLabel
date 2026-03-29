import SwiftUI

@main
struct SpaceNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra(appState.menuBarLabel) {
            SpaceListView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
    }
}

import SwiftUI

@main
struct SpaceLabelApp: App {
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
                    Image(nsImage: colorDot(color.color))
                }
                Text(appState.menuBarLabel)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: appState.menuBarLabel)
            }
        }
        .menuBarExtraStyle(.window)
    }

    /// Render a colored dot as a non-template NSImage so macOS doesn't strip the color.
    private func colorDot(_ color: Color) -> NSImage {
        let size: CGFloat = 8
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            NSColor(color).setFill()
            NSBezierPath(ovalIn: rect).fill()
            return true
        }
        image.isTemplate = false
        return image
    }
}

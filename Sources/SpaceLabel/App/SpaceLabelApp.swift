import SwiftUI

@main
struct SpaceLabelApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @ObservedObject private var settings = AppSettings.shared

    var body: some Scene {
        MenuBarExtra {
            SpaceListView()
                .environmentObject(appState)
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        let color = appState.currentColorTag
            .flatMap { tag in SpaceProfile.availableColors.first(where: { $0.name == tag })?.color }

        switch settings.menuBarIndicator {
        case .none:
            animatedText
        case .dot:
            HStack(spacing: 4) {
                if let color {
                    Image(nsImage: colorDot(color))
                }
                animatedText
            }
        case .underline:
            Image(nsImage: underlineLabel(appState.menuBarLabel, color: color.map { NSColor($0) } ?? .labelColor))
        }
    }

    private var animatedText: some View {
        Text(appState.menuBarLabel)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: appState.menuBarLabel)
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

    /// Render the label text with a colored underline as a non-template NSImage.
    /// The text uses `labelColor` so it still adapts to the menu bar appearance,
    /// while the underline keeps the space's color (which a template image would strip).
    private func underlineLabel(_ text: String, color: NSColor) -> NSImage {
        let font = NSFont.systemFont(ofSize: 13)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.labelColor,
        ]
        let textSize = (text as NSString).size(withAttributes: attributes)
        let underlineThickness: CGFloat = 2
        let gap: CGFloat = 1
        let width = max(ceil(textSize.width), 1)
        let height = ceil(textSize.height) + gap + underlineThickness

        let image = NSImage(size: NSSize(width: width, height: height), flipped: false) { _ in
            (text as NSString).draw(at: NSPoint(x: 0, y: gap + underlineThickness), withAttributes: attributes)
            let lineRect = NSRect(x: 0, y: 0, width: width, height: underlineThickness)
            color.setFill()
            NSBezierPath(roundedRect: lineRect, xRadius: underlineThickness / 2, yRadius: underlineThickness / 2).fill()
            return true
        }
        image.isTemplate = false
        return image
    }
}

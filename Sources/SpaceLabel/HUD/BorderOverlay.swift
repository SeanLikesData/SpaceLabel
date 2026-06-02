import AppKit

/// Draws a stroked frame inset so the full line width stays on screen.
final class BorderView: NSView {
    var color: NSColor = .clear { didSet { needsDisplay = true } }
    var thickness: CGFloat = 4 { didSet { needsDisplay = true } }

    override func draw(_ dirtyRect: NSRect) {
        guard thickness > 0 else { return }
        let inset = thickness / 2
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let path = NSBezierPath(rect: rect)
        path.lineWidth = thickness
        color.setStroke()
        path.stroke()
    }
}

/// Borderless, click-through panel that shows on every space.
final class BorderPanel: NSPanel {
    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        isMovableByWindowBackground = false
        hidesOnDeactivate = false
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

/// Keeps one border panel per screen, all showing the current space's color.
/// Because the panels join all spaces, switching spaces just recolors them.
final class BorderOverlayController {
    private var panels: [BorderPanel] = []

    func update(color: NSColor?, thickness: CGFloat, enabled: Bool) {
        guard enabled, let color, thickness > 0 else {
            hide()
            return
        }

        let screens = NSScreen.screens
        while panels.count < screens.count { panels.append(makePanel()) }
        while panels.count > screens.count { panels.removeLast().orderOut(nil) }

        for (i, screen) in screens.enumerated() {
            let panel = panels[i]
            panel.setFrame(screen.frame, display: true)
            if let view = panel.contentView as? BorderView {
                view.frame = NSRect(origin: .zero, size: screen.frame.size)
                view.color = color
                view.thickness = thickness
            }
            panel.orderFrontRegardless()
        }
    }

    private func makePanel() -> BorderPanel {
        let panel = BorderPanel()
        panel.contentView = BorderView()
        return panel
    }

    private func hide() {
        for panel in panels { panel.orderOut(nil) }
    }
}

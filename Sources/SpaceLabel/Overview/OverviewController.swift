import AppKit
import SwiftUI

/// One row of the all-spaces overview, snapshotted when the panel opens.
struct OverviewRow: Identifiable {
    let id: String
    let index: Int
    let name: String
    let colorName: String?
    let notesPreview: String
    let isCurrent: Bool
}

/// Floating card that can take key focus so Escape and click-away dismiss it.
final class OverviewPanel: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 520),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovableByWindowBackground = true
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Shows and hides the overview panel, centered on the screen under the mouse.
final class OverviewController: NSObject, NSWindowDelegate {
    private var panel: OverviewPanel?
    private static let panelSize = NSSize(width: 440, height: 520)

    func toggle(rows: [OverviewRow]) {
        if panel != nil {
            close()
        } else {
            show(rows: rows)
        }
    }

    private func show(rows: [OverviewRow]) {
        let panel = OverviewPanel()
        panel.delegate = self

        let view = OverviewView(rows: rows, onClose: { [weak self] in self?.close() })
        let host = NSHostingView(rootView: view)
        host.frame = NSRect(origin: .zero, size: Self.panelSize)
        panel.contentView = host

        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first(where: { $0.frame.contains(mouse) }) ?? NSScreen.main
        if let frame = screen?.visibleFrame {
            panel.setFrameOrigin(NSPoint(
                x: frame.midX - Self.panelSize.width / 2,
                y: frame.midY - Self.panelSize.height / 2
            ))
        }

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }

    private func close() {
        panel?.orderOut(nil)
        panel = nil
    }

    func windowDidResignKey(_ notification: Notification) {
        close()
    }
}

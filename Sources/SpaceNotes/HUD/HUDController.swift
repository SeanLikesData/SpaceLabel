import AppKit
import SwiftUI

final class HUDController {
    private var panels: [HUDPanel] = []
    private var hideTimer: Timer?

    func show(name: String, index: Int, notes: String = "", colorTag: String? = nil) {
        hideTimer?.invalidate()

        let screens = NSScreen.screens
        // Reuse or create panels to match screen count
        while panels.count < screens.count { panels.append(HUDPanel()) }
        while panels.count > screens.count { panels.removeLast().orderOut(nil) }

        let hasNotes = !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let panelHeight: CGFloat = hasNotes ? 110 : 80
        let hudView = HUDView(name: name, index: index, notes: notes, colorTag: colorTag)

        for (i, screen) in screens.enumerated() {
            let panel = panels[i]
            let hostView = NSHostingView(rootView: hudView)
            hostView.frame = NSRect(x: 0, y: 0, width: 320, height: panelHeight)

            panel.contentView = hostView
            panel.setContentSize(NSSize(width: 320, height: panelHeight))
            panel.centerOn(screen: screen)
            panel.alphaValue = 1
            panel.orderFrontRegardless()
        }

        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.fadeOut()
        }
    }

    private func fadeOut() {
        for panel in panels {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                panel.animator().alphaValue = 0
            }, completionHandler: {
                panel.orderOut(nil)
            })
        }
    }
}

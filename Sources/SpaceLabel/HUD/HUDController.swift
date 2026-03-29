import AppKit
import SwiftUI

final class HUDController {
    private var panels: [HUDPanel] = []
    private var hideTimer: Timer?
    private var showGeneration: Int = 0

    func show(name: String, index: Int, notes: String = "", colorTag: String? = nil) {
        hideTimer?.invalidate()
        showGeneration += 1
        let currentGeneration = showGeneration

        let screens = NSScreen.screens
        // Reuse or create panels to match screen count
        while panels.count < screens.count { panels.append(HUDPanel()) }
        while panels.count > screens.count { panels.removeLast().orderOut(nil) }

        let hasNotes = !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let panelHeight: CGFloat = hasNotes ? 110 : 80
        let hudView = HUDView(name: name, index: index, notes: notes, colorTag: colorTag)

        for (i, screen) in screens.enumerated() {
            let panel = panels[i]
            // Cancel any in-progress fade animation
            panel.animator().alphaValue = 1
            let hostView = NSHostingView(rootView: hudView)
            hostView.frame = NSRect(x: 0, y: 0, width: 320, height: panelHeight)

            panel.contentView = hostView
            panel.setContentSize(NSSize(width: 320, height: panelHeight))
            panel.centerOn(screen: screen)
            panel.alphaValue = 1
            panel.orderFrontRegardless()
        }

        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.fadeOut(generation: currentGeneration)
        }
    }

    private func fadeOut(generation: Int) {
        guard generation == showGeneration else { return }
        let gen = generation
        for panel in panels {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                panel.animator().alphaValue = 0
            }, completionHandler: { [weak self] in
                // Only remove if no newer show() has fired
                guard let self, gen == self.showGeneration else { return }
                panel.orderOut(nil)
            })
        }
    }
}

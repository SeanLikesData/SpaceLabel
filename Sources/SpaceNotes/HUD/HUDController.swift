import AppKit
import SwiftUI

final class HUDController {
    private var panels: [HUDPanel] = []
    private var hideTimer: Timer?

    func show(name: String, index: Int) {
        hideTimer?.invalidate()

        let screens = NSScreen.screens
        // Reuse or create panels to match screen count
        while panels.count < screens.count { panels.append(HUDPanel()) }
        while panels.count > screens.count { panels.removeLast().orderOut(nil) }

        let hudView = HUDView(name: name, index: index)

        for (i, screen) in screens.enumerated() {
            let panel = panels[i]
            let hostView = NSHostingView(rootView: hudView)
            hostView.frame = NSRect(x: 0, y: 0, width: 320, height: 80)

            panel.contentView = hostView
            panel.setContentSize(NSSize(width: 320, height: 80))
            panel.centerOn(screen: screen)
            panel.alphaValue = 0
            panel.orderFrontRegardless()

            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                panel.animator().alphaValue = 1
            }
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

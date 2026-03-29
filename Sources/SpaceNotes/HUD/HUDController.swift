import AppKit
import SwiftUI

final class HUDController {
    private let panel = HUDPanel()
    private var hideTimer: Timer?

    func show(name: String, index: Int) {
        hideTimer?.invalidate()

        let hudView = HUDView(name: name, index: index)
        let hostView = NSHostingView(rootView: hudView)
        hostView.frame = NSRect(x: 0, y: 0, width: 320, height: 80)

        panel.contentView = hostView
        panel.setContentSize(NSSize(width: 320, height: 80))
        panel.centerOnMainScreen()
        panel.alphaValue = 0

        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            panel.animator().alphaValue = 1
        }

        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.fadeOut()
        }
    }

    private func fadeOut() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.panel.orderOut(nil)
        })
    }
}

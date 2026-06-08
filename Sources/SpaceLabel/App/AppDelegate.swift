import AppKit
import Carbon
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private static weak var shared: AppDelegate?

    private let menuBarGap: CGFloat = 1
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let appState = AppState()
    private let settings = AppSettings.shared

    private var panel: SpaceLabelPanel?
    private var hotKeyRef: EventHotKeyRef?
    private var cancellables = Set<AnyCancellable>()
    private var sizeObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.shared = self
        configureStatusItem()
        installMainMenu()
        createPanel()
        observeState()
        registerHotKey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let sizeObserver {
            NotificationCenter.default.removeObserver(sizeObserver)
        }
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(togglePopover)
        button.imagePosition = .imageOnly
        updateStatusItem(
            label: appState.menuBarLabel,
            colorTag: appState.currentColorTag,
            indicator: settings.menuBarIndicator
        )
    }

    private func installMainMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(
            withTitle: "Quit SpaceLabel",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }

    private func createPanel() {
        let size = NSSize(width: settings.popoverSize.width, height: settings.popoverSize.height)
        let panel = SpaceLabelPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentViewController = NSHostingController(
            rootView: SpaceLabelPanelContent()
                .environmentObject(appState)
        )
        self.panel = panel
    }

    private func observeState() {
        appState.$menuBarLabel
            .combineLatest(appState.$currentColorTag, settings.$menuBarIndicator)
            .receive(on: RunLoop.main)
            .sink { [weak self] label, colorTag, indicator in
                self?.updateStatusItem(label: label, colorTag: colorTag, indicator: indicator)
            }
            .store(in: &cancellables)

        sizeObserver = NotificationCenter.default.addObserver(
            forName: .spaceLabelPopoverSizeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let size = notification.object as? NSSize else { return }
            self?.resizePanel(to: size)
        }
    }

    @objc private func togglePopover() {
        if panel?.isVisible == true {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let panel else { return }
        NSApp.activate(ignoringOtherApps: true)
        positionPanel()
        panel.orderFrontRegardless()
        panel.makeKey()
    }

    private func closePopover() {
        panel?.orderOut(nil)
    }

    private func resizePanel(to size: NSSize) {
        guard let panel else { return }
        panel.setContentSize(size)
        if panel.isVisible {
            positionPanel()
        }
    }

    private func positionPanel() {
        guard let panel, let button = statusItem.button, let buttonWindow = button.window else { return }

        let size = panel.frame.size
        let buttonFrameInWindow = button.convert(button.bounds, to: nil)
        let buttonFrameOnScreen = buttonWindow.convertToScreen(buttonFrameInWindow)
        var origin = NSPoint(
            x: buttonFrameOnScreen.midX - (size.width / 2),
            y: buttonFrameOnScreen.minY - size.height - menuBarGap
        )

        if let screen = buttonWindow.screen ?? NSScreen.main {
            let visibleFrame = screen.visibleFrame
            origin.x = max(visibleFrame.minX + 8, min(origin.x, visibleFrame.maxX - size.width - 8))
            origin.y = max(visibleFrame.minY + 8, min(origin.y, visibleFrame.maxY - size.height - 8))
        }

        panel.setFrameOrigin(origin)
    }

    private func updateStatusItem(label: String, colorTag: String?, indicator: MenuBarIndicator) {
        guard let button = statusItem.button else { return }
        let color = colorTag
            .flatMap { tag in SpaceProfile.availableColors.first(where: { $0.name == tag })?.color }
            .map(NSColor.init)

        button.image = menuBarImage(
            text: label,
            color: color ?? .labelColor,
            indicator: indicator
        )
        button.toolTip = label
    }

    private func menuBarImage(
        text: String,
        color: NSColor,
        indicator: MenuBarIndicator
    ) -> NSImage {
        let font = NSFont.systemFont(ofSize: 13)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.labelColor,
        ]
        let textSize = (text as NSString).size(withAttributes: attributes)
        let dotSize: CGFloat = indicator == .dot ? 8 : 0
        let dotGap: CGFloat = indicator == .dot ? 4 : 0
        let underlineThickness: CGFloat = indicator == .underline ? 2 : 0
        let underlineGap: CGFloat = indicator == .underline ? 1 : 0
        let width = max(ceil(textSize.width) + dotSize + dotGap, 1)
        let height = ceil(textSize.height) + underlineGap + underlineThickness

        let image = NSImage(size: NSSize(width: width, height: height), flipped: false) { _ in
            let textOrigin = NSPoint(
                x: dotSize + dotGap,
                y: underlineGap + underlineThickness
            )
            (text as NSString).draw(at: textOrigin, withAttributes: attributes)

            if indicator == .dot {
                color.setFill()
                let dotY = underlineGap + underlineThickness + (textSize.height - dotSize) / 2
                NSBezierPath(ovalIn: NSRect(x: 0, y: dotY, width: dotSize, height: dotSize)).fill()
            } else if indicator == .underline {
                color.setFill()
                let lineRect = NSRect(x: 0, y: 0, width: width, height: underlineThickness)
                NSBezierPath(
                    roundedRect: lineRect,
                    xRadius: underlineThickness / 2,
                    yRadius: underlineThickness / 2
                ).fill()
            }
            return true
        }
        image.isTemplate = false
        return image
    }

    private func registerHotKey() {
        let hotKeyID = EventHotKeyID(signature: OSType(0x534C424C), id: 1)
        let modifiers = UInt32(controlKey)
        RegisterEventHotKey(
            UInt32(kVK_ANSI_Slash),
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let handler: EventHandlerUPP = { _, _, _ -> OSStatus in
            AppDelegate.shared?.togglePopover()
            return noErr
        }
        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            nil,
            nil
        )
    }
}

final class SpaceLabelPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

private struct SpaceLabelPanelContent: View {
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
            SpaceListView()
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }
}

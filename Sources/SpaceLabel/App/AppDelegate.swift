import AppKit
import Carbon

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var popoverHotKeyRef: EventHotKeyRef?
    private var overviewHotKeyRef: EventHotKeyRef?

    private static let signature = OSType(0x534C424C) // "SLBL"
    private static let popoverHotKeyID: UInt32 = 1
    private static let overviewHotKeyID: UInt32 = 2

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerHotKeys()
    }

    private func registerHotKeys() {
        // Control + / toggles the popover.
        popoverHotKeyRef = register(
            keyCode: UInt32(kVK_ANSI_Slash),
            modifiers: UInt32(controlKey),
            id: Self.popoverHotKeyID
        )
        // Control + Shift + / toggles the all-spaces overview.
        overviewHotKeyRef = register(
            keyCode: UInt32(kVK_ANSI_Slash),
            modifiers: UInt32(controlKey | shiftKey),
            id: Self.overviewHotKeyID
        )

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        let handler: EventHandlerUPP = { _, event, _ -> OSStatus in
            var hkID = EventHotKeyID()
            GetEventParameter(event,
                              EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID),
                              nil,
                              MemoryLayout<EventHotKeyID>.size,
                              nil,
                              &hkID)
            switch hkID.id {
            case AppDelegate.popoverHotKeyID:
                AppDelegate.togglePopover()
            case AppDelegate.overviewHotKeyID:
                DispatchQueue.main.async { AppState.shared?.toggleOverview() }
            default:
                break
            }
            return noErr
        }
        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, nil, nil)
    }

    private func register(keyCode: UInt32, modifiers: UInt32, id: UInt32) -> EventHotKeyRef? {
        let hotKeyID = EventHotKeyID(signature: Self.signature, id: id)
        var ref: EventHotKeyRef?
        RegisterEventHotKey(keyCode, modifiers, hotKeyID,
                            GetApplicationEventTarget(), 0, &ref)
        return ref
    }

    private static func togglePopover() {
        // Find the MenuBarExtra's status item button and click it
        for window in NSApp.windows {
            guard let statusItem = window.value(forKey: "statusItem") as? NSStatusItem,
                  let button = statusItem.button else { continue }
            button.performClick(nil)
            return
        }
    }
}

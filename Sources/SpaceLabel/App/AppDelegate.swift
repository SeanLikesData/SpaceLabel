import AppKit
import Carbon

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerHotKey()
    }

    private func registerHotKey() {
        // Control + / (slash, keycode 44)
        let hotKeyID = EventHotKeyID(signature: OSType(0x534C424C), // "SLBL"
                                      id: 1)
        var ref: EventHotKeyRef?
        let modifiers: UInt32 = UInt32(controlKey)
        RegisterEventHotKey(UInt32(kVK_ANSI_Slash), modifiers, hotKeyID,
                            GetApplicationEventTarget(), 0, &ref)
        hotKeyRef = ref

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        let handler: EventHandlerUPP = { _, _, _ -> OSStatus in
            AppDelegate.togglePopover()
            return noErr
        }
        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, nil, nil)
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

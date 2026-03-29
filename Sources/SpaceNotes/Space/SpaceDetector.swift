import AppKit

// CGS private API declarations via @_silgen_name (avoids C bridge module entirely)
@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

@_silgen_name("CGSGetActiveSpace")
func CGSGetActiveSpace(_ connection: Int32) -> UInt64

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ connection: Int32) -> CFArray

@_silgen_name("CGSManagedDisplaySetCurrentSpace")
func CGSManagedDisplaySetCurrentSpace(_ connection: Int32, _ display: CFString, _ space: UInt64)

@_silgen_name("CGSAddWindowsToSpaces")
func CGSAddWindowsToSpaces(_ connection: Int32, _ windows: NSArray, _ spaces: NSArray)

@_silgen_name("CGSRemoveWindowsFromSpaces")
func CGSRemoveWindowsFromSpaces(_ connection: Int32, _ windows: NSArray, _ spaces: NSArray)

final class SpaceDetector: ObservableObject {
    @Published private(set) var currentSpaceUUID: String = ""
    @Published private(set) var allSpaces: [SpaceInfo] = []
    @Published private(set) var removedSpaceUUIDs: Set<String> = []

    private var knownSpaceUUIDs: Set<String> = []
    private var observer: NSObjectProtocol?
    private var refreshTimer: Timer?
    private var helperWindow: NSWindow?

    init() {
        refresh()
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
        // Periodic refresh to detect space add/remove (no notification for these)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    deinit {
        if let observer { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
        refreshTimer?.invalidate()
    }

    func refresh() {
        let conn = CGSMainConnectionID()
        let activeID = CGSGetActiveSpace(conn)

        guard let displaysInfo = CGSCopyManagedDisplaySpaces(conn) as? [[String: Any]] else {
            return
        }

        var spaces: [SpaceInfo] = []
        var currentUUID = ""

        for display in displaysInfo {
            let displayID = display["Display Identifier"] as? String ?? "unknown"
            guard let spacesList = display["Spaces"] as? [[String: Any]] else { continue }

            for (index, space) in spacesList.enumerated() {
                guard let managedID = space["ManagedSpaceID"] as? Int64,
                      let uuid = space["uuid"] as? String else { continue }

                // Filter out fullscreen app spaces (type 4)
                let type = space["type"] as? Int ?? 0
                guard type == 0 else { continue }

                let isCurrent = Int64(activeID) == managedID
                if isCurrent { currentUUID = uuid }

                let info = SpaceInfo(
                    uuid: uuid,
                    managedID: managedID,
                    index: index + 1,
                    displayID: displayID,
                    isCurrentSpace: isCurrent
                )
                spaces.append(info)
            }
        }

        let newUUIDs = Set(spaces.map(\.uuid))
        if !knownSpaceUUIDs.isEmpty {
            let removed = knownSpaceUUIDs.subtracting(newUUIDs)
            if !removed.isEmpty {
                removedSpaceUUIDs = removed
            }
        }
        knownSpaceUUIDs = newUUIDs

        self.allSpaces = spaces
        self.currentSpaceUUID = currentUUID
    }

    func switchTo(space: SpaceInfo) {
        let conn = CGSMainConnectionID()
        let currentSpaceID = CGSGetActiveSpace(conn)

        // Create an invisible helper window anchored on the current space
        let helper = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        helper.collectionBehavior = [.transient, .ignoresCycle]
        helper.isOpaque = false
        helper.backgroundColor = .clear
        helper.alphaValue = 0
        helper.orderFrontRegardless()
        self.helperWindow = helper

        let wid = NSNumber(value: helper.windowNumber)
        let currentSID = NSNumber(value: currentSpaceID)
        let targetSID = NSNumber(value: space.managedID)

        // Move helper from current space to target space
        CGSRemoveWindowsFromSpaces(conn, [wid] as NSArray, [currentSID] as NSArray)
        CGSAddWindowsToSpaces(conn, [wid] as NSArray, [targetSID] as NSArray)

        // Tell the WindowServer which space is now current
        CGSManagedDisplaySetCurrentSpace(conn, space.displayID as CFString, UInt64(space.managedID))

        // Focus the helper window to trigger the visual space transition
        helper.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        // Clean up after transition completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.helperWindow?.close()
            self?.helperWindow = nil
        }
    }
}

import AppKit

// CGS private API declarations via @_silgen_name (avoids C bridge module entirely)
@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

@_silgen_name("CGSGetActiveSpace")
func CGSGetActiveSpace(_ connection: Int32) -> UInt64

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ connection: Int32) -> CFArray

// Switch a display to a specific space. Private and undocumented; behavior can
// vary by macOS version, so this powers an experimental click-to-jump feature.
@_silgen_name("CGSManagedDisplaySetCurrentSpace")
func CGSManagedDisplaySetCurrentSpace(_ connection: Int32, _ display: CFString, _ space: UInt64)

final class SpaceDetector: ObservableObject {
    @Published private(set) var currentSpaceUUID: String = ""
    @Published private(set) var allSpaces: [SpaceInfo] = []
    @Published private(set) var removedSpaceUUIDs: Set<String> = []

    private var knownSpaceUUIDs: Set<String> = []
    private var observer: NSObjectProtocol?
    private var refreshTimer: Timer?

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

    /// Experimental: switch to the given space via a private CGS call.
    func switchToSpace(_ space: SpaceInfo) {
        let conn = CGSMainConnectionID()
        CGSManagedDisplaySetCurrentSpace(conn, space.displayID as CFString, UInt64(space.managedID))
        refresh()
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
}

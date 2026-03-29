import AppKit

// CGS private API declarations via @_silgen_name (avoids C bridge module entirely)
@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

@_silgen_name("CGSGetActiveSpace")
func CGSGetActiveSpace(_ connection: Int32) -> UInt64

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ connection: Int32) -> CFArray

final class SpaceDetector: ObservableObject {
    @Published private(set) var currentSpaceUUID: String = ""
    @Published private(set) var allSpaces: [SpaceInfo] = []

    private var observer: NSObjectProtocol?

    init() {
        refresh()
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
    }

    deinit {
        if let observer { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
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

        self.allSpaces = spaces
        self.currentSpaceUUID = currentUUID
    }
}

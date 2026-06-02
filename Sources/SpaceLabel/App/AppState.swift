import AppKit
import Combine
import SwiftUI

final class AppState: ObservableObject {
    /// Set on init so the Carbon hotkey handler in AppDelegate can reach the
    /// live state without an injected reference.
    static private(set) var shared: AppState?

    let detector = SpaceDetector()
    let store = SpaceDataStore()
    let hudController = HUDController()
    let borderController = BorderOverlayController()
    let overviewController = OverviewController()

    @Published var menuBarLabel: String = "Desktop"
    @Published private(set) var currentProfile: SpaceProfile = SpaceProfile(id: "")
    @Published var currentColorTag: String? = nil

    private var cancellables = Set<AnyCancellable>()
    private var previousSpaceUUID: String = ""

    init() {
        Self.shared = self

        detector.$currentSpaceUUID
            .combineLatest(store.$profiles)
            .receive(on: RunLoop.main)
            .sink { [weak self] uuid, profiles in
                guard let self, !uuid.isEmpty else { return }
                var profile = profiles[uuid] ?? SpaceProfile(id: uuid)
                let spaceIndex = self.detector.allSpaces.first(where: { $0.uuid == uuid })?.index ?? 0

                // Auto-assign a color the first time a space is seen without one.
                // Persisting it makes the color stable for that space from then on.
                if profile.colorTag == nil {
                    let palette = SpaceProfile.availableColors
                    profile.colorTag = palette[(max(spaceIndex, 1) - 1) % palette.count].name
                    self.store.save(profile)
                }

                self.currentProfile = profile
                self.currentColorTag = profile.colorTag

                let label = profile.name.isEmpty ? "Desktop \(spaceIndex)" : profile.name
                self.menuBarLabel = String(label.prefix(20))

                if self.previousSpaceUUID != uuid && !self.previousSpaceUUID.isEmpty {
                    self.hudController.show(
                        name: profile.name.isEmpty ? "Desktop \(spaceIndex)" : profile.name,
                        index: spaceIndex,
                        notes: profile.notes,
                        colorTag: profile.colorTag
                    )
                }
                self.previousSpaceUUID = uuid
            }
            .store(in: &cancellables)

        // Clean up orphaned profiles when spaces are removed
        detector.$removedSpaceUUIDs
            .receive(on: RunLoop.main)
            .sink { [weak self] removed in
                guard let self, !removed.isEmpty else { return }
                self.store.removeProfiles(for: removed)
            }
            .store(in: &cancellables)

        // Redraw the desktop border when the current color or border settings change.
        let settings = AppSettings.shared
        $currentColorTag
            .combineLatest(settings.$borderEnabled, settings.$borderThickness, settings.$borderOpacity)
            .receive(on: RunLoop.main)
            .sink { [weak self] colorTag, enabled, thickness, opacity in
                self?.updateBorder(colorTag: colorTag, enabled: enabled, thickness: thickness, opacity: opacity)
            }
            .store(in: &cancellables)
    }

    func saveProfile(_ profile: SpaceProfile) {
        store.save(profile)
        detector.refresh()
    }

    /// Open or close the all-spaces overview, snapshotting current data.
    func toggleOverview() {
        let rows = detector.allSpaces
            .sorted { $0.index < $1.index }
            .map { space -> OverviewRow in
                let profile = store.profile(for: space.uuid)
                return OverviewRow(
                    id: space.uuid,
                    index: space.index,
                    name: profile.name,
                    colorName: profile.colorTag,
                    notes: profile.notes,
                    isCurrent: space.uuid == detector.currentSpaceUUID
                )
            }
        overviewController.toggle(
            rows: rows,
            onSave: { [weak self] row in self?.updateProfile(from: row) },
            onJump: { [weak self] uuid in self?.jumpToSpace(uuid) }
        )
    }

    /// Experimental: switch to the desktop with the given space UUID.
    private func jumpToSpace(_ uuid: String) {
        guard let space = detector.allSpaces.first(where: { $0.uuid == uuid }) else { return }
        detector.switchToSpace(space)
    }

    /// Persist an edit made from the overview, keyed by the row's space UUID.
    private func updateProfile(from row: OverviewRow) {
        let profile = SpaceProfile(
            id: row.id,
            name: row.name,
            notes: row.notes,
            colorTag: row.colorName,
            lastEdited: Date()
        )
        store.save(profile)
    }

    private func updateBorder(colorTag: String?, enabled: Bool, thickness: Double, opacity: Double) {
        let color: NSColor? = colorTag
            .flatMap { tag in SpaceProfile.availableColors.first(where: { $0.name == tag })?.color }
            .map { NSColor($0) }
        borderController.update(
            color: color,
            thickness: CGFloat(thickness),
            opacity: CGFloat(opacity),
            enabled: enabled
        )
    }
}

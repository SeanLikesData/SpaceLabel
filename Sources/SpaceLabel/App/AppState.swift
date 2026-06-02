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
            .combineLatest(settings.$borderEnabled, settings.$borderThickness)
            .receive(on: RunLoop.main)
            .sink { [weak self] colorTag, enabled, thickness in
                self?.updateBorder(colorTag: colorTag, enabled: enabled, thickness: thickness)
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
                let preview = profile.notes
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .components(separatedBy: .newlines)
                    .prefix(2)
                    .joined(separator: "\n")
                return OverviewRow(
                    id: space.uuid,
                    index: space.index,
                    name: profile.name.isEmpty ? "Desktop \(space.index)" : profile.name,
                    colorName: profile.colorTag,
                    notesPreview: preview,
                    isCurrent: space.uuid == detector.currentSpaceUUID
                )
            }
        overviewController.toggle(rows: rows)
    }

    private func updateBorder(colorTag: String?, enabled: Bool, thickness: Double) {
        let color: NSColor? = colorTag
            .flatMap { tag in SpaceProfile.availableColors.first(where: { $0.name == tag })?.color }
            .map { NSColor($0) }
        borderController.update(color: color, thickness: CGFloat(thickness), enabled: enabled)
    }
}

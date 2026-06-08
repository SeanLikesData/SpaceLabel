import Combine
import SwiftUI

final class AppState: ObservableObject {
    let detector = SpaceDetector()
    let store = SpaceDataStore()
    let hudController = HUDController()

    @Published var menuBarLabel: String = "Desktop"
    @Published private(set) var currentProfile: SpaceProfile = SpaceProfile(id: "")
    @Published var currentColorTag: String? = nil

    private var cancellables = Set<AnyCancellable>()
    private var previousSpaceUUID: String = ""

    init() {
        detector.$currentSpaceUUID
            .combineLatest(store.$profiles, store.$projects)
            .receive(on: RunLoop.main)
            .sink { [weak self] uuid, _, _ in
                guard let self, !uuid.isEmpty else { return }
                var profile = self.store.profile(for: uuid)
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
    }

    func saveProfile(_ profile: SpaceProfile) {
        store.save(profile)
        detector.refresh()
    }

    @discardableResult
    func createProject(from profile: SpaceProfile) -> String {
        let projectID = store.createProject(from: profile)
        detector.refresh()
        return projectID
    }

    func assignProject(_ projectID: String?, to spaceUUID: String) {
        store.assignProject(projectID, to: spaceUUID)
        detector.refresh()
    }

    func clearSpace(_ spaceUUID: String) {
        store.clearSpace(spaceUUID)
        detector.refresh()
    }
}

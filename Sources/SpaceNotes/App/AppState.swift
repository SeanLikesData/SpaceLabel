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
            .combineLatest(store.$profiles)
            .receive(on: RunLoop.main)
            .sink { [weak self] uuid, profiles in
                guard let self, !uuid.isEmpty else { return }
                let profile = profiles[uuid] ?? SpaceProfile(id: uuid)
                self.currentProfile = profile
                self.currentColorTag = profile.colorTag

                let spaceIndex = self.detector.allSpaces.first(where: { $0.uuid == uuid })?.index ?? 0
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
}

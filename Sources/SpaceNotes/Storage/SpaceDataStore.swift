import Foundation

final class SpaceDataStore: ObservableObject {
    private let key = "SpaceNotes.profiles"
    @Published private(set) var profiles: [String: SpaceProfile] = [:]

    init() {
        load()
    }

    func profile(for uuid: String) -> SpaceProfile {
        profiles[uuid] ?? SpaceProfile(id: uuid)
    }

    func save(_ profile: SpaceProfile) {
        profiles[profile.id] = profile
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: SpaceProfile].self, from: data)
        else { return }
        profiles = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

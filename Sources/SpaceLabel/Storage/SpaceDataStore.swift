import Foundation

final class SpaceDataStore: ObservableObject {
    private let profilesKey = "SpaceLabel.profiles"
    private let projectsKey = "SpaceLabel.projects"
    private let defaults: UserDefaults

    @Published private(set) var profiles: [String: SpaceProfile] = [:]
    @Published private(set) var projects: [String: SavedProject] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func profile(for uuid: String) -> SpaceProfile {
        let profile = profiles[uuid] ?? SpaceProfile(id: uuid)
        guard let projectID = profile.projectID,
              let project = projects[projectID]
        else { return profile }

        return SpaceProfile(
            id: uuid,
            name: project.name,
            notes: project.notes,
            colorTag: project.colorTag,
            lastEdited: project.lastEdited,
            projectID: projectID
        )
    }

    func save(_ profile: SpaceProfile) {
        if let projectID = profile.projectID, projects[projectID] != nil {
            projects[projectID] = SavedProject(
                id: projectID,
                name: profile.name,
                notes: profile.notes,
                colorTag: profile.colorTag,
                lastEdited: profile.lastEdited
            )

            var assignment = profiles[profile.id] ?? SpaceProfile(id: profile.id)
            assignment.projectID = projectID
            profiles[profile.id] = assignment
        } else {
            profiles[profile.id] = profile
        }
        persist()
    }

    @discardableResult
    func createProject(from profile: SpaceProfile) -> String {
        let project = SavedProject(
            name: profile.name,
            notes: profile.notes,
            colorTag: profile.colorTag,
            lastEdited: profile.lastEdited
        )
        projects[project.id] = project

        var assignment = profiles[profile.id] ?? profile
        assignment.projectID = project.id
        profiles[profile.id] = assignment
        persist()
        return project.id
    }

    func assignProject(_ projectID: String?, to spaceUUID: String) {
        var profile = profiles[spaceUUID] ?? SpaceProfile(id: spaceUUID)
        profile.projectID = projectID.flatMap { projects[$0] == nil ? nil : $0 }
        profiles[spaceUUID] = profile
        persist()
    }

    func clearSpace(_ spaceUUID: String) {
        profiles[spaceUUID] = SpaceProfile(id: spaceUUID)
        persist()
    }

    func removeProfiles(for uuids: Set<String>) {
        for uuid in uuids {
            guard let profile = profiles[uuid] else { continue }
            // Only remove if name AND notes are empty
            if profile.name.isEmpty && profile.notes.isEmpty && profile.projectID == nil {
                profiles.removeValue(forKey: uuid)
            }
        }
        persist()
    }

    private func load() {
        if let data = defaults.data(forKey: profilesKey),
           let decoded = try? JSONDecoder().decode([String: SpaceProfile].self, from: data) {
            profiles = decoded
        }
        if let data = defaults.data(forKey: projectsKey),
           let decoded = try? JSONDecoder().decode([String: SavedProject].self, from: data) {
            projects = decoded
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(profiles) {
            defaults.set(data, forKey: profilesKey)
        }
        if let data = try? JSONEncoder().encode(projects) {
            defaults.set(data, forKey: projectsKey)
        }
    }
}

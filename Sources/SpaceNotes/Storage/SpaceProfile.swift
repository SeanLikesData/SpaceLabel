import Foundation

struct SpaceProfile: Codable, Identifiable, Equatable {
    var id: String // space UUID
    var name: String
    var notes: String

    init(id: String, name: String = "", notes: String = "") {
        self.id = id
        self.name = name
        self.notes = notes
    }
}

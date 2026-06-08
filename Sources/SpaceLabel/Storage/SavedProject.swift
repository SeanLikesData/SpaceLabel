import Foundation

struct SavedProject: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var notes: String
    var colorTag: String?
    var lastEdited: Date?

    init(
        id: String = UUID().uuidString,
        name: String,
        notes: String = "",
        colorTag: String? = nil,
        lastEdited: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.colorTag = colorTag
        self.lastEdited = lastEdited
    }
}

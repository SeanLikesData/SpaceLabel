import Foundation
import SwiftUI

struct SpaceProfile: Codable, Identifiable, Equatable {
    var id: String // space UUID
    var name: String
    var notes: String
    var colorTag: String?
    var lastEdited: Date?
    var projectID: String?

    init(
        id: String,
        name: String = "",
        notes: String = "",
        colorTag: String? = nil,
        lastEdited: Date? = nil,
        projectID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.colorTag = colorTag
        self.lastEdited = lastEdited
        self.projectID = projectID
    }

    static let availableColors: [(name: String, color: Color)] = [
        ("red", .red),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("blue", .blue),
        ("purple", .purple),
        ("pink", .pink),
    ]

    // Equatable: exclude computed-only helpers
    static func == (lhs: SpaceProfile, rhs: SpaceProfile) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.notes == rhs.notes
            && lhs.colorTag == rhs.colorTag && lhs.lastEdited == rhs.lastEdited
            && lhs.projectID == rhs.projectID
    }

    var tagColor: Color? {
        guard let colorTag else { return nil }
        return Self.availableColors.first(where: { $0.name == colorTag })?.color
    }
}

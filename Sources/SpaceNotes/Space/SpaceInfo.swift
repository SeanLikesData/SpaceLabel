import Foundation

struct SpaceInfo: Identifiable, Equatable {
    let uuid: String
    let managedID: Int64
    let index: Int
    let displayID: String
    let isCurrentSpace: Bool

    var id: String { uuid }
}

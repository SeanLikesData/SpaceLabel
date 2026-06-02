import Foundation

/// How the space color appears next to the menu bar label.
enum MenuBarIndicator: String, CaseIterable, Identifiable {
    case none
    case dot
    case underline

    var id: String { rawValue }

    var label: String {
        switch self {
        case .none: return "None"
        case .dot: return "Dot"
        case .underline: return "Underline"
        }
    }
}

/// User-facing preferences persisted in UserDefaults.
/// Single shared instance so views and controllers observe the same state.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var notesExpanded: Bool {
        didSet { defaults.set(notesExpanded, forKey: Keys.notesExpanded) }
    }

    @Published var menuBarIndicator: MenuBarIndicator {
        didSet { defaults.set(menuBarIndicator.rawValue, forKey: Keys.menuBarIndicator) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let notesExpanded = "SpaceLabel.notesExpanded"
        static let menuBarIndicator = "SpaceLabel.menuBarIndicator"
    }

    private init() {
        notesExpanded = defaults.bool(forKey: Keys.notesExpanded)
        // Default to the colored dot (the original behavior).
        let savedIndicator = defaults.string(forKey: Keys.menuBarIndicator)
        menuBarIndicator = savedIndicator.flatMap(MenuBarIndicator.init(rawValue:)) ?? .dot
    }
}

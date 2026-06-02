import Foundation

/// User-facing preferences persisted in UserDefaults.
/// Single shared instance so views and controllers observe the same state.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var notesExpanded: Bool {
        didSet { defaults.set(notesExpanded, forKey: Keys.notesExpanded) }
    }

    /// Draw a colored frame around each screen in the current space's color.
    @Published var borderEnabled: Bool {
        didSet { defaults.set(borderEnabled, forKey: Keys.borderEnabled) }
    }

    /// Border line width in points.
    @Published var borderThickness: Double {
        didSet { defaults.set(borderThickness, forKey: Keys.borderThickness) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let notesExpanded = "SpaceLabel.notesExpanded"
        static let borderEnabled = "SpaceLabel.borderEnabled"
        static let borderThickness = "SpaceLabel.borderThickness"
    }

    private init() {
        notesExpanded = defaults.bool(forKey: Keys.notesExpanded)
        borderEnabled = defaults.bool(forKey: Keys.borderEnabled)
        // Default to 4pt the first time (UserDefaults returns 0 for a missing key).
        let savedThickness = defaults.double(forKey: Keys.borderThickness)
        borderThickness = savedThickness == 0 ? 4 : savedThickness
    }
}

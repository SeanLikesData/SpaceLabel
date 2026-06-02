import Foundation

/// User-facing preferences persisted in UserDefaults.
/// Single shared instance so views and controllers observe the same state.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var notesExpanded: Bool {
        didSet { defaults.set(notesExpanded, forKey: Keys.notesExpanded) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let notesExpanded = "SpaceLabel.notesExpanded"
    }

    private init() {
        notesExpanded = defaults.bool(forKey: Keys.notesExpanded)
    }
}

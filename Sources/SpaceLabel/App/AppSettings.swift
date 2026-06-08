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

/// Fixed dimensions available for the menu bar popover.
enum PopoverSize: String, CaseIterable, Identifiable {
    case small
    case medium
    case large

    var id: String { rawValue }

    var label: String {
        rawValue.capitalized
    }

    var width: CGFloat {
        switch self {
        case .small: return 300
        case .medium: return 340
        case .large: return 400
        }
    }

    var height: CGFloat {
        switch self {
        case .small: return 360
        case .medium: return 440
        case .large: return 560
        }
    }

    var dimensionsLabel: String {
        "\(Int(width)) x \(Int(height)) points"
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

    @Published var popoverSize: PopoverSize {
        didSet { defaults.set(popoverSize.rawValue, forKey: Keys.popoverSize) }
    }

    @Published var markdownRendering: Bool {
        didSet { defaults.set(markdownRendering, forKey: Keys.markdownRendering) }
    }

    @Published var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let notesExpanded = "SpaceLabel.notesExpanded"
        static let menuBarIndicator = "SpaceLabel.menuBarIndicator"
        static let popoverSize = "SpaceLabel.popoverSize"
        static let markdownRendering = "SpaceLabel.markdownRendering"
        static let launchAtLogin = "SpaceLabel.launchAtLogin"
    }

    private init() {
        notesExpanded = defaults.bool(forKey: Keys.notesExpanded)
        markdownRendering = defaults.bool(forKey: Keys.markdownRendering)
        launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        // Default to the colored dot (the original behavior).
        let savedIndicator = defaults.string(forKey: Keys.menuBarIndicator)
        menuBarIndicator = savedIndicator.flatMap(MenuBarIndicator.init(rawValue:)) ?? .dot
        let savedPopoverSize = defaults.string(forKey: Keys.popoverSize)
        popoverSize = savedPopoverSize.flatMap(PopoverSize.init(rawValue:)) ?? .medium
    }
}

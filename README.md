# SpaceLabel

A lightweight macOS menu bar app for naming and organizing your desktop spaces.

macOS gives you multiple desktop spaces, but no way to label them. SpaceLabel fixes that — name each space, tag it with a color, jot notes, and see where you are with a HUD overlay every time you switch.

## Features

- **Name your spaces** — give each desktop space a project name like "Blog Redesign" or "Tax Prep"
- **Color tags** — assign one of 7 colors; shown as a colored dot in the menu bar, a tint on the HUD, and in the popover
- **Notes** — free-form notes per space, auto-saved when the popover closes
- **HUD overlay** — instantly shows the space name, number, notes preview, and color tint when you switch desktops
- **Global hotkey** — `Control + /` toggles the popover from anywhere
- **Escape to close** — press Escape to save and dismiss
- **Persistent** — names, notes, and colors survive app restarts and reboots (stored in UserDefaults)
- **Space lifecycle** — automatically detects when spaces are added or removed and cleans up orphaned profiles

## Screenshots

> Coming soon

## Requirements

- macOS 15.0+
- Apple Silicon (arm64)

## Install

### Build from source

```bash
git clone https://github.com/SeanLikesData/SpaceLabel.git
cd SpaceLabel
./Scripts/build.sh
```

The build script compiles with `swiftc`, assembles a `.app` bundle, and launches it. The resulting app is at `.build/SpaceLabel.app`.

To install permanently:

```bash
cp -r .build/SpaceLabel.app /Applications/
```

To start on login: **System Settings > General > Login Items > "+" > SpaceLabel**

## How It Works

SpaceLabel uses Apple's private CoreGraphics Server (CGS) APIs to detect desktop spaces — there's no public API for this. Functions like `CGSGetActiveSpace` and `CGSCopyManagedDisplaySpaces` are called via Swift's `@_silgen_name` attribute, avoiding the need for a C bridging module.

The app listens for `NSWorkspace.activeSpaceDidChangeNotification` to detect space switches in real time, and polls every 10 seconds to catch space additions/removals (which don't fire notifications).

The HUD overlay uses a borderless `NSPanel` with `canJoinAllSpaces` so it appears on every desktop. The menu bar color dot is rendered as a non-template `NSImage` to bypass macOS's monochrome template rendering.

### Build system note

The project uses `swiftc` directly rather than Swift Package Manager due to a bug in the macOS Command Line Tools where a duplicate `SwiftBridging` module map causes compilation failures. The build script creates a patched toolchain symlink tree as a workaround.

## Project Structure

```
Sources/SpaceLabel/
├── App/
│   ├── SpaceLabelApp.swift    # @main entry, MenuBarExtra with colored dot label
│   ├── AppState.swift         # Central state: detector + store + HUD via Combine
│   └── AppDelegate.swift      # Global hotkey registration (Control+/)
├── Space/
│   ├── SpaceDetector.swift    # CGS private API wrapper for space detection
│   └── SpaceInfo.swift        # Space data model (UUID, managedID, index, display)
├── Storage/
│   ├── SpaceProfile.swift     # Codable model: name, notes, colorTag, lastEdited
│   └── SpaceDataStore.swift   # UserDefaults persistence layer
├── Views/
│   ├── SpaceListView.swift    # Popover container
│   └── SpaceDetailView.swift  # Edit name, notes, color tag
└── HUD/
    ├── HUDView.swift          # SwiftUI HUD with vibrancy + color tint
    ├── HUDPanel.swift         # Borderless NSPanel configuration
    └── HUDController.swift    # Show/hide lifecycle with timer
```

## License

MIT

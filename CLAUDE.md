# SpaceLabel

macOS menu bar app for labeling desktops with project names.

## Build

```bash
./Scripts/build.sh    # compiles, assembles .app, and launches
```

Uses `swiftc` directly (not SPM) due to CLT toolchain mismatch. The build script creates a patched toolchain symlink tree to work around a duplicate `SwiftBridging` module.modulemap in the CLT.

## Architecture

- **AppKit NSStatusItem + NSPanel** for a popover that remains visible when other applications activate; panel content is SwiftUI
- **CGS private APIs** via `@_silgen_name` for space detection (no C bridge module)
- **NSPanel** HUD overlay on desktop switch (with notes preview + color tint)
- **UserDefaults** persistence keyed by space UUID
- `LSUIElement = true` — menu bar only, no dock icon

## Features

- Debounced autosave of notes while typing, plus save on popover close and before quit (no explicit Save button)
- Saved projects can be assigned from a dropdown; project name, notes, and color persist independently of a desktop space
- Color auto-assigned per space (7-color palette, by index), overridable in the picker
- Menu bar indicator setting (none / dot / underline) for how the space color shows by the label; underline renders as a non-template NSImage
- Popover size setting with Small (300 x 360), Medium (340 x 440), and Large (400 x 560) presets; Medium is the default
- Expandable notes editor (toggle in the Notes header), preference persisted
- Notes preview (first 2 lines) in HUD overlay
- Relative timestamp for last edit
- Space add/remove detection with orphan profile cleanup (10s polling)

## Key Files

- `Sources/SpaceLabel/App/SpaceLabelApp.swift` — AppKit @main entry point
- `Sources/SpaceLabel/App/AppDelegate.swift` — status item, persistent panel, menu bar label, and global hotkey
- `Sources/SpaceLabel/App/AppState.swift` — central state combining detector + store + HUD
- `Sources/SpaceLabel/App/AppSettings.swift` — UserDefaults-backed preferences, including popover size
- `Sources/SpaceLabel/Space/SpaceDetector.swift` — CGS space detection + change notifications
- `Sources/SpaceLabel/Storage/SavedProject.swift` — reusable project data
- `Sources/SpaceLabel/Storage/SpaceDataStore.swift` — local profiles, saved projects, and space assignments
- `Sources/SpaceLabel/Views/SpaceListView.swift` — popover container (detail or settings)
- `Sources/SpaceLabel/Views/SpaceDetailView.swift` — edit name + notes + color; autosave
- `Sources/SpaceLabel/Views/SettingsView.swift` — popover size and menu bar indicator pickers
- `Sources/SpaceLabel/HUD/` — floating overlay on space change

# SpaceNotes

macOS menu bar app for labeling desktops with project names.

## Build

```bash
./Scripts/build.sh    # compiles, assembles .app, and launches
```

Uses `swiftc` directly (not SPM) due to CLT toolchain mismatch. The build script creates a patched toolchain symlink tree to work around a duplicate `SwiftBridging` module.modulemap in the CLT.

## Architecture

- **SwiftUI MenuBarExtra** with `.window` style for the popover
- **CGS private APIs** via `@_silgen_name` for space detection (no C bridge module)
- **NSPanel** HUD overlay on desktop switch
- **UserDefaults** persistence keyed by space UUID
- `LSUIElement = true` — menu bar only, no dock icon

## Key Files

- `Sources/SpaceNotes/App/SpaceNotesApp.swift` — @main entry point
- `Sources/SpaceNotes/App/AppState.swift` — central state combining detector + store
- `Sources/SpaceNotes/Space/SpaceDetector.swift` — CGS space detection + change notifications
- `Sources/SpaceNotes/Views/SpaceListView.swift` — popover list of desktops
- `Sources/SpaceNotes/Views/SpaceDetailView.swift` — edit name + notes
- `Sources/SpaceNotes/HUD/` — floating overlay on space change

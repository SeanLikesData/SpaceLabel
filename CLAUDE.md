# SpaceNotes

macOS menu bar app for labeling desktops with project names.

## Build

```bash
./Scripts/build.sh    # compiles, assembles .app, and launches
```

Uses `swiftc` directly (not SPM) due to CLT toolchain mismatch. The build script creates a patched toolchain symlink tree to work around a duplicate `SwiftBridging` module.modulemap in the CLT.

## Architecture

- **SwiftUI MenuBarExtra** with `.window` style and view builder label (colored dot + animated text)
- **CGS private APIs** via `@_silgen_name` for space detection + switching (no C bridge module)
- **NSPanel** HUD overlay on desktop switch (with notes preview + color tint)
- **UserDefaults** persistence keyed by space UUID
- `LSUIElement = true` — menu bar only, no dock icon

## Features

- Auto-save on popover close (no explicit Save button)
- Color tags (7 colors) shown in menu bar, HUD, and switch list
- Notes preview (first 2 lines) in HUD overlay
- Relative timestamp for last edit
- Quick-switch to other desktops from popover
- Space add/remove detection with orphan profile cleanup (10s polling)
- Animated menu bar label with content transition

## Key Files

- `Sources/SpaceNotes/App/SpaceNotesApp.swift` — @main entry point
- `Sources/SpaceNotes/App/AppState.swift` — central state combining detector + store
- `Sources/SpaceNotes/Space/SpaceDetector.swift` — CGS space detection + change notifications
- `Sources/SpaceNotes/Views/SpaceListView.swift` — popover list of desktops
- `Sources/SpaceNotes/Views/SpaceDetailView.swift` — edit name + notes
- `Sources/SpaceNotes/HUD/` — floating overlay on space change

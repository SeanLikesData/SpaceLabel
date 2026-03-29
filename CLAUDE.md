# SpaceLabel

macOS menu bar app for labeling desktops with project names.

## Build

```bash
./Scripts/build.sh    # compiles, assembles .app, and launches
```

Uses `swiftc` directly (not SPM) due to CLT toolchain mismatch. The build script creates a patched toolchain symlink tree to work around a duplicate `SwiftBridging` module.modulemap in the CLT.

## Architecture

- **SwiftUI MenuBarExtra** with `.window` style and view builder label (colored dot + animated text)
- **CGS private APIs** via `@_silgen_name` for space detection (no C bridge module)
- **NSPanel** HUD overlay on desktop switch (with notes preview + color tint)
- **UserDefaults** persistence keyed by space UUID
- `LSUIElement = true` — menu bar only, no dock icon

## Features

- Auto-save on popover close (no explicit Save button)
- Color tags (7 colors) shown in menu bar and HUD
- Notes preview (first 2 lines) in HUD overlay
- Relative timestamp for last edit
- Space add/remove detection with orphan profile cleanup (10s polling)
- Animated menu bar label with content transition

## Key Files

- `Sources/SpaceLabel/App/SpaceLabelApp.swift` — @main entry point
- `Sources/SpaceLabel/App/AppState.swift` — central state combining detector + store
- `Sources/SpaceLabel/Space/SpaceDetector.swift` — CGS space detection + change notifications
- `Sources/SpaceLabel/Views/SpaceListView.swift` — popover list of desktops
- `Sources/SpaceLabel/Views/SpaceDetailView.swift` — edit name + notes
- `Sources/SpaceLabel/HUD/` — floating overlay on space change

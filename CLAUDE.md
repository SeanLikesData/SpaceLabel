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

- Debounced autosave of notes while typing, plus save on popover close and before quit (no explicit Save button)
- Color auto-assigned per space (7-color palette, by index), overridable in the picker
- Menu bar indicator setting (none / dot / underline) for how the space color shows by the label; underline renders as a non-template NSImage
- Expandable notes editor (toggle in the Notes header), preference persisted
- Notes preview (first 2 lines) in HUD overlay
- Relative timestamp for last edit
- Space add/remove detection with orphan profile cleanup (10s polling)
- Animated menu bar label with content transition

## Key Files

- `Sources/SpaceLabel/App/SpaceLabelApp.swift` — @main entry point; menu bar label (dot/underline/none)
- `Sources/SpaceLabel/App/AppState.swift` — central state combining detector + store + HUD
- `Sources/SpaceLabel/App/AppSettings.swift` — UserDefaults-backed preferences
- `Sources/SpaceLabel/App/AppDelegate.swift` — Carbon hotkey (Control+/)
- `Sources/SpaceLabel/Space/SpaceDetector.swift` — CGS space detection + change notifications
- `Sources/SpaceLabel/Views/SpaceListView.swift` — popover container (detail or settings)
- `Sources/SpaceLabel/Views/SpaceDetailView.swift` — edit name + notes + color; autosave
- `Sources/SpaceLabel/Views/SettingsView.swift` — menu bar indicator picker
- `Sources/SpaceLabel/HUD/` — floating overlay on space change

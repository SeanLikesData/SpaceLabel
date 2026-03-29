#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/.build"
APP_NAME="SpaceLabel"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

cd "$PROJECT_DIR"

echo "Building $APP_NAME..."
mkdir -p "$BUILD_DIR"

# --- Workaround for CLT bug: duplicate SwiftBridging module.modulemap ---
# Creates a patched toolchain symlink tree that excludes the duplicate file
PATCHED_DIR="$BUILD_DIR/patched-toolchain/usr"
if [ ! -d "$PATCHED_DIR/include/swift" ]; then
    mkdir -p "$PATCHED_DIR/include/swift"
    mkdir -p "$PATCHED_DIR/lib"
    ln -sf /Library/Developer/CommandLineTools/usr/lib/swift "$PATCHED_DIR/lib/swift"
    ln -sf /Library/Developer/CommandLineTools/usr/bin "$PATCHED_DIR/bin"
    for f in /Library/Developer/CommandLineTools/usr/include/swift/*; do
        name=$(basename "$f")
        [ "$name" != "module.modulemap" ] && ln -sf "$f" "$PATCHED_DIR/include/swift/$name"
    done
    for d in /Library/Developer/CommandLineTools/usr/include/*; do
        name=$(basename "$d")
        [ "$name" != "swift" ] && ln -sf "$d" "$PATCHED_DIR/include/$name"
    done
fi
RESOURCE_DIR="$(cd "$PATCHED_DIR/lib/swift" && pwd)"
# --- End workaround ---

# Collect all Swift source files
SWIFT_FILES=()
while IFS= read -r -d '' file; do
    SWIFT_FILES+=("$file")
done < <(find Sources/SpaceLabel -name "*.swift" -type f -print0)

echo "Compiling ${#SWIFT_FILES[@]} Swift files..."

swiftc \
    -o "$BUILD_DIR/$APP_NAME" \
    -framework AppKit \
    -framework SwiftUI \
    -framework CoreGraphics \
    -target arm64-apple-macosx15.0 \
    -O \
    -parse-as-library \
    -swift-version 5 \
    -suppress-warnings \
    -resource-dir "$RESOURCE_DIR" \
    "${SWIFT_FILES[@]}"

EXECUTABLE="$BUILD_DIR/$APP_NAME"
if [ ! -f "$EXECUTABLE" ]; then
    echo "ERROR: Build failed — executable not found"
    exit 1
fi

echo "Assembling $APP_NAME.app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.spacelabel.app</string>
    <key>CFBundleName</key>
    <string>SpaceLabel</string>
    <key>CFBundleDisplayName</key>
    <string>SpaceLabel</string>
    <key>CFBundleExecutable</key>
    <string>SpaceLabel</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

echo "Build complete: $APP_BUNDLE"

# Kill existing instance if running
pkill -f "$APP_NAME.app/Contents/MacOS/$APP_NAME" 2>/dev/null || true
sleep 0.5

echo "Launching $APP_NAME..."
open "$APP_BUNDLE"
echo "Done."

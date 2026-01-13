#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="ImmichSync"
BUILD_DIR_UNIVERSAL="$ROOT_DIR/.build/apple/Products/Release"
BUILD_DIR_ARM="$ROOT_DIR/.build/arm64-apple-macosx/release"
BUILD_DIR_X64="$ROOT_DIR/.build/x86_64-apple-macosx/release"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/${APP_NAME}.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

cd "$ROOT_DIR"

swift build -c release --arch arm64 --arch x86_64

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

if [[ -f "$BUILD_DIR_UNIVERSAL/$APP_NAME" ]]; then
  cp "$BUILD_DIR_UNIVERSAL/$APP_NAME" "$MACOS_DIR/$APP_NAME"
else
  xcrun lipo -create \
    "$BUILD_DIR_ARM/$APP_NAME" \
    "$BUILD_DIR_X64/$APP_NAME" \
    -output "$MACOS_DIR/$APP_NAME"
fi
cp "$ROOT_DIR/Sources/ImmichSync/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"

cat <<PLIST > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.bjoernch.ImmichSync</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Built: $APP_DIR"

# Refresh release artifacts alongside the app bundle
"$ROOT_DIR/scripts/package-release.sh" --skip-build

#!/bin/sh
# Builds "Vial Keyboard Layers.app" into hotkey/mac-app/build/.
# Needs the Xcode command line tools (swiftc). Run from anywhere: sh hotkey/mac-app/build.sh
# The app shows this repo's index.html from where it is now, so rebuild if you move the repo.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
BUILD="$HERE/build"
APP="$BUILD/Vial Keyboard Layers.app"
EXE="VialKeyboardLayers"

rm -rf "$APP" "$BUILD/AppIcon.iconset"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$BUILD/AppIcon.iconset"

echo "Compiling..."
swiftc -O -swift-version 5 \
  -target "$(uname -m)-apple-macos13.0" \
  -framework AppKit -framework WebKit \
  -o "$APP/Contents/MacOS/$EXE" \
  "$HERE/VialKeyboardLayers.swift"

echo "Making the icon..."
ICONSET="$BUILD/AppIcon.iconset"
for size in 16 32 128 256 512; do
  sips -z $size $size "$REPO/icon-512.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  [ $double -le 512 ] && sips -z $double $double "$REPO/icon-512.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns -o "$APP/Contents/Resources/AppIcon.icns" "$ICONSET"
rm -rf "$ICONSET"

cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>$EXE</string>
  <key>CFBundleIdentifier</key><string>com.dileeparanawake.vial-keyboard-layers</string>
  <key>CFBundleName</key><string>Vial Keyboard Layers</string>
  <key>CFBundleDisplayName</key><string>Vial Keyboard Layers</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
  <key>VLIndexPath</key><string></string>
</dict>
</plist>
EOF
# plutil escapes the path properly (spaces, &, and so on).
plutil -replace VLIndexPath -string "$REPO/index.html" "$APP/Contents/Info.plist"

echo "Signing (ad hoc)..."
codesign --force --sign - "$APP"

echo "Built: $APP"
echo "Shows: $REPO/index.html"

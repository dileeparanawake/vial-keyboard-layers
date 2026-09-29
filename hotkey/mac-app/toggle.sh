#!/bin/sh
# Shows or hides the layer map as its own app. Point a hotkey at this (Alfred, Raycast, Shortcuts).
# Press it with the map closed and it opens; press it again and the app quits.
# Optional first argument: a layer number, or "all" (the default). It applies when the app opens.
# Build the app first: sh hotkey/mac-app/build.sh
# Needs no macOS Automation permission: it quits the app with a signal, not AppleScript.
HERE="$(cd "$(dirname "$0")" && pwd)"
APP="$HERE/build/Vial Keyboard Layers.app"
RUNNING='/Contents/MacOS/VialKeyboardLayers( |$)'

if pgrep -f "$RUNNING" >/dev/null; then
  pkill -f "$RUNNING"  # the app quits the normal way on this signal, saving its window and storage
  exit 0
fi

if [ ! -d "$APP" ]; then
  echo "Build the app first: sh \"$HERE/build.sh\"" >&2
  exit 1
fi
open "$APP" --args --layer "${1:-all}"

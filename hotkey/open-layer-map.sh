#!/bin/sh
# Opens the layer map in its own small Chrome window (no tabs, no address bar).
# Point a hotkey at this: macOS Shortcuts, Karabiner-Elements, Alfred or Raycast.
# Optional first argument: a layer number, or "all" (the default).
DIR="$(cd "$(dirname "$0")/.." && pwd)"
LAYER="${1:-all}"
open -na "Google Chrome" --args --app="file://$DIR/index.html?layer=$LAYER" --window-size=1400,760

#!/bin/sh
# Shows or hides the layer map in its own small Chrome window (no tabs, no address bar).
# Point a hotkey at this: macOS Shortcuts, Karabiner-Elements, Alfred or Raycast.
# Press it with the map closed and it opens; press it again and the map's window closes.
# It opens where it was last closed (by this hotkey), the same size; the first time, it fits the screen.
# Optional first argument: a layer number, or "all" (the default).
# The first time, macOS asks whether your hotkey app may control Google Chrome: allow it, or the
# map opens but never closes.
DIR="$(cd "$(dirname "$0")/.." && pwd)"
LAYER="${1:-all}"
PAGE="file://$DIR/index.html"
SAVED="$HOME/Library/Application Support/vial-keyboard-layers/window"

# Close any open map window (only windows showing this page; other Chrome windows are left alone),
# and print where the last one was: left,top,right,bottom. Asks nothing of Chrome when it isn't running.
BOUNDS=$(osascript - "$PAGE" <<'EOF' 2>/dev/null
on run argv
  set page to item 1 of argv
  if application "Google Chrome" is not running then return ""
  set found to ""
  tell application "Google Chrome"
    -- By id, not position: closing a window renumbers the rest.
    repeat with wid in (get id of every window)
      if (URL of active tab of window id wid) starts with page then
        set b to bounds of window id wid
        set found to ((item 1 of b) as text) & "," & (item 2 of b) & "," & (item 3 of b) & "," & (item 4 of b)
        close window id wid
      end if
    end repeat
  end tell
  return found
end run
EOF
)
if [ -n "$BOUNDS" ]; then
  mkdir -p "$(dirname "$SAVED")"
  echo "$BOUNDS" > "$SAVED"
  exit 0
fi

# Where to open: where it was last, else 1400 by 800, no bigger than the screen, centred.
# (Reading the screen size needs no permission.)
if [ -f "$SAVED" ]; then
  IFS=, read -r L T R B < "$SAVED"
else
  SCREEN=$(osascript -l JavaScript -e 'ObjC.import("AppKit"); const f = $.NSScreen.mainScreen.visibleFrame; [Math.round(f.size.width), Math.round(f.size.height)].join(",")' 2>/dev/null)
  SW=${SCREEN%,*}; SH=${SCREEN#*,}
  [ -z "$SCREEN" ] && SW=1400 && SH=800
  W=$(( SW * 95 / 100 )); [ "$W" -gt 1400 ] && W=1400
  H=$(( SH * 95 / 100 )); [ "$H" -gt 800 ] && H=800
  L=$(( (SW - W) / 2 )); T=$(( (SH - H) / 2 + 25 )); R=$(( L + W )); B=$(( T + H ))
fi

open -na "Google Chrome" --args --app="$PAGE?layer=$LAYER" --window-size="$((R - L)),$((B - T))"

# A running Chrome ignores the size and place asked for above, and puts back its own a moment after
# the window opens. So set them once the window is up, and again until they hold (up to 5 seconds).
osascript - "$PAGE" "$L" "$T" "$R" "$B" <<'EOF' >/dev/null 2>&1
on run argv
  set page to item 1 of argv
  set b to {(item 2 of argv) as integer, (item 3 of argv) as integer, (item 4 of argv) as integer, (item 5 of argv) as integer}
  set held to 0
  repeat 50 times
    -- A window only just opened may have no tab yet; try again on the next pass.
    try
      tell application "Google Chrome"
        repeat with wid in (get id of every window)
          if (URL of active tab of window id wid) starts with page then
            if (bounds of window id wid) is b then
              set held to held + 1
            else
              set held to 0
              set bounds of window id wid to b
            end if
          end if
        end repeat
      end tell
    end try
    if held ≥ 5 then return
    delay 0.1
  end repeat
end run
EOF

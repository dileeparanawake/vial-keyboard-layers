#!/usr/bin/env python3
"""Embed a .vil file, and notes.json, into index.html as the built-in defaults.

Usage: python3 tools/embed.py [path/to/layout.vil]
Defaults to layouts/miryoku-11.vil. Rewrites the block between the
@default-vil-start and @default-vil-end markers in index.html, and, if
notes.json exists beside index.html, the block between @default-notes-start
and @default-notes-end. The embedded copies are what the page uses when it is
opened as a file (double-click, or the hotkey), where it cannot read notes.json.
"""
import json
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
src = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else root / "layouts" / "miryoku-11.vil"
html_path = root / "index.html"
notes_path = root / "notes.json"


def compact(data):
    return json.dumps(data, separators=(",", ":"), ensure_ascii=False).replace("</", "<\\/")


def replace_block(html, name, element_id, payload):
    block = (
        f"<!-- @{name}-start -->\n"
        f'<script type="application/json" id="{element_id}">{payload}</script>\n'
        f"<!-- @{name}-end -->"
    )
    new, n = re.subn(rf"<!-- @{name}-start -->.*?<!-- @{name}-end -->", lambda _: block, html, flags=re.S)
    if n != 1:
        sys.exit(f"@{name} markers not found in index.html")
    return new


html = html_path.read_text(encoding="utf-8")
vil = compact(json.loads(src.read_text(encoding="utf-8")))
html = replace_block(html, "default-vil", "default-vil", vil)
print(f"Embedded {src.name} ({len(vil)} bytes)")
if notes_path.exists():
    notes = json.loads(notes_path.read_text(encoding="utf-8"))
    payload = compact({"uid": notes.get("uid"), "notes": notes.get("notes", {})})
    html = replace_block(html, "default-notes", "default-notes", payload)
    print(f"Embedded notes.json ({len(notes.get('notes', {}))} names)")
html_path.write_text(html, encoding="utf-8")

# Reading the layout straight from the keyboard (route, not built)

Possible from this page in Chrome, Edge or Arc, served from `localhost` (a secure context) or opened as a file. **Read only: nothing below writes to the keyboard.** Checked against vial-gui's source (`protocol/constants.py`, `keyboard_comm.py`, `util.py`, `keycodes/keycodes_v6.py`) on 25 September 2026. **Not yet checked, confirm first:** the macro buffer format and the leading status byte on tap dance replies (both from memory of vial-gui's macro and dynamic-entry code).

**Why it is not built yet.** It can only be tested with a keyboard plugged in and a click on Chrome's device chooser, and it needs two pieces the page does not have: a table turning 16-bit keycodes back into names, and a macro-buffer parser.

**Connecting.** A button click calls `navigator.hid.requestDevice({ filters: [{ usagePage: 0xFF60, usage: 0x61 }] })` (the raw HID interface VIA and Vial share; vial-gui also checks the serial number contains `vial:f64c2b3c`). Every message is a 32-byte output report, report id 0; the reply arrives as a 32-byte `inputreport`. Send one command, wait for its reply, then the next.

**Commands, in order** (multi-byte fields as marked: BE big-endian, LE little-endian):

| Step | Send | Reply |
|---|---|---|
| Which keyboard | `FE 00` | protocol version (u32 LE), keyboard uid (u64 LE). The uid matches the `.vil` file's `uid` |
| Layer count | `11` | byte 1 is the number of layers |
| Keymap | `12`, offset (u16 BE), size (u8, up to 28) | keycodes from byte 4, 2 bytes each, BE. Read `layers x rows x cols x 2` bytes in chunks; key at `(layer x rows x cols + row x cols + col) x 2` |
| Tap dance count | `FE 0D 00` | byte 0 tap dances, 1 combos, 2 key overrides, 3 alt repeat keys; last byte feature flags |
| Each tap dance | `FE 0D 01`, index | on tap, on hold, on double tap, on tap then hold (u16 LE keycodes), tapping term (u16 LE ms), after a leading status byte |
| Macros | `0C` count, `0D` buffer size (u16 BE), `0E` offset (u16 BE) size (u8) for the buffer | macros are NUL-separated; keystroke actions are prefixed `01` (tap `01`, down `02`, up `03`, delay `04`) |

**Rows and columns.** The keymap read needs the matrix size, which Vial keeps in its definition: `FE 01` gives the size (u32 LE), `FE 02` plus a block number (u32 LE) gives it 32 bytes at a time, LZMA-compressed JSON with `matrix.rows` and `matrix.cols`. A browser has no built-in LZMA, so the smallest route skips it: **when the uid matches a loaded `.vil`, take rows and columns from that file** (a Corne is 8 x 7). Only a keyboard never seen as a `.vil` needs the decompressor.

**Numbers back to names** (QMK keycodes v6, used from `vial_protocol` 6): `0x0000` none, `0x0001` transparent, `0x0004`-`0x00FF` basic keys (HID usage codes), `0x0100`-`0x1FFF` mods wrapped round a key (bits 8-12: Ctrl, Shift, Alt, GUI, right-hand), `0x2000` mod-tap, `0x4000` layer-tap (layer in bits 8-11), `0x5000` layer-mod, `0x5200` TO, `0x5220` MO, `0x5240` DF, `0x5260` TG, `0x5280` OSL, `0x52A0` OSM, `0x52C0` TT, `0x5700` tap dance, `0x7700` macro. Turning each back into the names the `.vil` uses (`LSFT_T(KC_A)`, `TD(3)`) lets everything after the read reuse the existing parser, with a `.vil`-shaped object built in memory. Save it as the "last layout" so the map still opens with the keyboard unplugged.

**Tests without the keyboard.** Record the reply bytes once from a real session, then replay them in `test/` against a fake HID device.

What reading **cannot** show with stock firmware is which layer is active right now: neither VIA nor Vial reports layer state. That needs a small firmware change (send the layer over raw HID on `layer_state_set_user`), which means flashing.

# Vial Keyboard Layers

See every layer of your Vial keyboard layout on one screen, in plain words instead of raw keycodes.

![Vial Keyboard Layers showing all five layers of a Corne layout at once, each layer in its own colour](docs/screenshot-all-layers.png)

## Run it now

- **In a browser:** open **[dileeparanawake.github.io/vial-keyboard-layers](https://dileeparanawake.github.io/vial-keyboard-layers/)**. Nothing to install.
- **On a Mac, as its own app:** a Dock icon, works offline, one hotkey opens and quits it. See [C. Mac app](#c-as-its-own-mac-app-recommended-on-a-mac).
- **From a download:** download this repo and double-click `index.html`. No install, no server.

Then, in Vial, File, Save current layout, and drop the `.vil` on the page.

- **Nothing collected.** No account, no tracking, no uploads. Your `.vil` never leaves your machine.
- **Lightweight.** One HTML file, about 100 KB, no dependencies, no build step.
- **Four ways in.** A browser tab, an installed web app, its own Mac app, or a Chrome window on a hotkey. See [Ways to open it](#ways-to-open-it).

**Contents:** [Why](#why-it-exists) · [How to use it](#how-to-use-it) · [Ways to open it](#ways-to-open-it) · [Privacy](#privacy) · [What it works with](#what-it-works-with) · [Limitations](#limitations) · [Related tools](#related-tools) · [Files](#files)

## Why it exists

Learning a layered layout on a small keyboard means forgetting what is on each layer, a lot.

- **Vial shows one layer at a time**, with tap dances as `TD(3)` and mod-taps as raw codes. Answering "where is Page Down?" means opening the configurator, clicking through layers and decoding keycodes.
- **On a Mac, the Vial desktop app is Intel-only.** It runs through Rosetta, which Apple is winding down.

This page is the quick answer: one file, opened in a browser, showing every layer at once, Miryoku-style.

| Vial shows | This page shows |
|---|---|
| `LSFT_T(KC_A)` | **A**, with **Shift** on hold |
| `TD(3)` | **Space**, with **Nav** on hold |
| `LGUI(KC_Z)` | **Undo** |

Each key shows its base legend at the top left, then what it does on each other layer in words, one colour and one fixed place per layer, and what it does on hold at the bottom right.

## How to use it

1. **Open the page**, any of the [ways to open it](#ways-to-open-it). It opens with a built-in example layout.
2. **Save your layout from Vial.** File, Save current layout. That writes a `.vil` file.
3. **Load it.** Click **Load .vil** (the accented button in the toolbar, or press `O`) and choose the file, **or drop it anywhere on the page**.

Your layout shows straight away. A note says **Loaded your-file.vil · 5 layers**, and the Load button shows your file's name from then on, so you can always see which layout is on.

### Your layout is kept

- **It stays after a reload.** The last `.vil` you loaded is kept in that browser (local storage), so the page opens on your layout next time, not the example.
- **Your names stay with it.** Names you give keys and layers are kept per layout (by the keyboard's `uid`), so they come back whenever that layout is loaded.
- **Back to the example:** the round-arrow button beside Load .vil (it shows only while your own file is loaded). Your names are not deleted; load your file again and they are back.
- Loading another `.vil` replaces the one kept. Nothing leaves your machine.

### Reading the map

- **Hover or click a key** to see everything it does on every layer, in words, with the raw keycode alongside.
  - The tooltip puts each action on its own line: a tap dance's tap, hold, double-tap and tap then hold, and what Shift types.
  - Keys are drawn as keycaps. Hovering presses one half way. Clicking pins it, pressed down, until you click it again (or `Tab` to it and press `Enter`; `Esc` releases it).
  - With reduced motion set in your system, the keys change shade without moving.
- **Double-click a layer name** to rename it. Names are guessed from the contents (arrows make **Nav**, mouse keys **Mouse**, media keys **Media**, digits **Num**). Your renames are remembered per layout.
- **A + after a legend** means the key does more (double-tap, tap then hold). The single-layer view spells it out.
- **Small raised characters** after a digit or symbol are what Shift types, as on a keycap: `/?`, `3#`. More below.
- **An empty layer** is a small dimmed number in a dashed outline among the layer buttons. Click it (or press its number) and it says it's empty; it has no place on the keys.
- **Under the map:** the tap dances, macros, combos and key overrides in use.
- **Open on a layer:** `index.html?layer=1` opens straight onto layer 1; `?layer=all` onto the overview.
- **The credit bar stays pinned to the bottom** of the window, and the keyboard fits above it. **Built by Dileepa Ranawake** links to the author's GitHub profile, the GitHub icon to this repo, and the LinkedIn icon to LinkedIn.

<details>
<summary><b>Shortcuts</b></summary>

| Key | Does |
|---|---|
| `0` to `9` | Show that layer on its own, with larger legends. The key you hold to reach it is outlined and labelled |
| `Esc` or `A` | Back to all layers at once |
| `Left` / `Right` | Previous or next layer |
| `O` | Load your `.vil` |
| `M` | Mac or PC labels (Cmd and symbols, or Win and words) |
| `L` | US or UK keyboard layout on your computer, for what Shift types |
| `V` | Open Vial web in a new tab, to change the layout |
| `?` | Shortcut help |

</details>

<details>
<summary><b>What Shift types</b>: it follows your computer, not the keyboard</summary>

- It shows small and raised after a digit or symbol, as on a keycap: `/?`, `3#`. The single-layer view gives it its own line (`⇧ ?`), plus Opt or AltGr where that types a common symbol. Letters are left out, as Shift gives the capital.
- **It follows your computer's keyboard layout, not the keyboard.** The keyboard sends a key's place; your computer picks the character. The **US / UK** button (or `L`) sets which. It starts from your browser's language and is remembered.
  - On a British Mac, Shift+3 is `£` and Opt+3 is `#`.
  - On a UK PC, Shift+2 is `"`, Shift+' is `@`, and the `\` key types `#`.
- **A key override on Shift** (switched on in Vial, on that layer) replaces what Shift types, and the tooltip says so.

</details>

<details>
<summary><b>How it fits the window</b></summary>

The whole keyboard fits the window and scales with it. **Every layer's legend is shown in words on every key**, never as a dot. A legend too long for its line:

1. first gets narrower letters and smaller type (never below 9px),
2. then its row takes two lines,
3. then, if the window has the height, all the keys grow a little taller than wide,
4. and only if it still cannot fit is it shortened (`To Base` to `Base`, `Alfred clipboard` to `Clip`).

The full wording is always in the panel and the tooltip.

| Window | Keys | Smallest legend | Shortened |
|---|---|---|---|
| 1440 by 900 | 99px square | 12px | Nothing |
| 1000 by 600 | 68 by 73px | 9px | Nothing |
| 750 by 400 | 52 by 67px (taller than wide, to keep the words) | 9px | Nothing |

A window too small for 48px keys scrolls sideways rather than shrink them further. On a phone the two halves stack, left over right.

</details>

<details>
<summary><b>Naming what a key does</b>: macros, and keeping names with the page</summary>

Macros show as their keystrokes (`⌥⌘C`) until you name them. Pin a key, then use **Name** in the panel (one button per action: tap, hold, double-tap, tap then hold). Your name, such as **Alfred clipboard** for macro 3, then shows wherever that action appears.

**To keep names with the page** (they are kept in your browser):

1. Click **Export notes.json** (under the map) and save it over `notes.json` beside `index.html`.
2. Run `python3 tools/embed.py`, so the page also has them when opened by double-click. (A browser will not let a page opened as a file read the file next to it, so the names are copied into `index.html`.)

**When you change your layout, your names are checked.** A name on a macro remembers what that macro did when you named it. Load a newer `.vil` and:

| The macro | What happens |
|---|---|
| **Is the same** | Nothing to do. |
| **Changed** | The name shows with a **?** on the keys (**Alfred clipboard?**), and a note above the board says what it does now. Choose **Still right** or **Remove the name**. |
| **Moved to another slot** | The note offers **Move the name to macro 5**, or keep it where it was. |

**Import**, or dropping a `notes.json` on the page, loads a set. A `notes.json` names keycodes, so it only makes sense with the layout it was written for; its `uid` ties it to that keyboard.

</details>

## Ways to open it

| | A. Browser tab | B. Web app | C. Mac app | D. Chrome hotkey |
|---|---|---|---|---|
| **Install** | Nothing | From the browser menu | Download the repo, build once | Download the repo, set up a hotkey |
| **Own window** | No | Yes | Yes, with its own Dock icon | Yes, a Chrome window |
| **Works offline** | No | No | Yes | Yes |
| **Updates** | Always the published version | Always the published version | What you downloaded; `git pull`, no rebuild | What you downloaded; `git pull` to update |
| **Hotkey** | Through a launcher | Through a launcher | Yes: opens and quits it | Yes: opens and closes it, after you allow Chrome control once |
| **Platforms** | Any modern browser | Chrome or Edge on any OS, Safari 17+ on Mac | macOS 13+, no Chrome | macOS with Google Chrome |

**On a Mac, C is the simplest way to keep the map one key away.**

Your saved layout and names are kept in browser storage, which is separate for each browser and each site, and the Mac app has its own. So the hosted page, a downloaded copy and the Mac app do not share them. Load your `.vil` once in whichever you use.

### A. In a browser tab

Open [dileeparanawake.github.io/vial-keyboard-layers](https://dileeparanawake.github.io/vial-keyboard-layers/). Nothing to install. Needs internet.

### B. As an installed web app (no download)

Open the live page, then install it as its own app window:

- **Chrome:** the install button at the right of the address bar, or menu, **Cast, save and share**, **Install Vial Keyboard Layers**.
- **Edge:** menu, **Apps**, **Install this site as an app**.
- **Safari 17 or later, on a Mac:** File, **Add to Dock**.

Good to know:

- The menu item only shows on the live page, not on a copy opened from your disk.
- It then opens like any other app (on a Mac, from the Dock, Launchpad or Spotlight).
- A launcher such as Alfred, Raycast or macOS Shortcuts can give it a hotkey.
- It needs internet each time it opens, as the page is not cached for offline use.

### C. As its own Mac app (recommended on a Mac)

The same page, in a small Mac app of its own.

- **Its own Dock icon** (the keycap) and its own window.
- **Works offline.**
- **Remembers its size and place.**
- **One hotkey opens and quits it**, with no permission prompt for Chrome.

**Set it up**

1. Download or clone this repository.
2. If you don't have the Xcode command line tools, run `xcode-select --install`.
3. Build the app. It lands in `hotkey/mac-app/build/Vial Keyboard Layers.app`.

   ```
   sh /path/to/vial-keyboard-layers/hotkey/mac-app/build.sh
   ```

4. Open it. Run the same command again to quit it.

   ```
   sh /path/to/vial-keyboard-layers/hotkey/mac-app/toggle.sh
   ```

5. Point a hotkey at that `toggle.sh` command. See [Give it a hotkey](#give-it-a-hotkey).

**Good to know**

- **It keeps its own saved layout and names**, separate from your browser's. Load your `.vil` in it once.
- **`git pull` updates it without a rebuild.** It shows the `index.html` in your copy of the repo.
- **Rebuild if you move the folder.**
- Links out (**Edit in Vial**, the credit links) open in your normal browser.
- It needs macOS 13 or later, and the Xcode command line tools to build it.
- An optional argument opens a layer: `toggle.sh 1` opens layer 1.

### D. In a Chrome window, with a hotkey

The alternative if you'd rather not build the app. `hotkey/open-layer-map.sh` opens the local `index.html` as its own small Chrome window (Chrome's `--app` mode, with no tabs or address bar). The Dock shows Chrome. **Press the hotkey again and the window closes**, so one key shows and hides the map.

1. Download or clone this repository.
2. Point a hotkey at this command. See [Give it a hotkey](#give-it-a-hotkey).

   ```
   sh /path/to/vial-keyboard-layers/hotkey/open-layer-map.sh
   ```

3. **The first time you press it again to close the map, macOS asks whether your hotkey app (Alfred, Shortcuts, Karabiner) may control Google Chrome: choose Allow.** Without that, it opens the map but cannot close it. You can turn it on later in System Settings, Privacy & Security, Automation.

<details>
<summary>More about the Chrome script</summary>

- It opens again where it was, at the same size. The first time, it fits your screen (up to 1400 by 800).
- It only closes windows showing the map; your other Chrome windows are left alone.
- It is run with `sh`, so it does not need to be made executable.
- The window has no tabs, so links from it (**Edit in Vial**, the credit links) open in your normal Chrome window.
- An optional argument opens a layer: `open-layer-map.sh 1` opens layer 1.
- It needs macOS and Google Chrome.

</details>

### Give it a hotkey

A web page cannot catch a key while another app has focus, so C and D need something on the Mac to run their script. Use `hotkey/mac-app/toggle.sh` for the Mac app, or `hotkey/open-layer-map.sh` for Chrome.

| Tool | How |
|---|---|
| **macOS Shortcuts** (built in) | New shortcut, add **Run Shell Script** with the command, then in the shortcut's details choose **Add Keyboard Shortcut**. |
| **Alfred** (Powerpack) | A workflow with a **Hotkey** trigger, then **Run Script** with the command. |
| **Karabiner-Elements** | Edit the path in `hotkey/karabiner-vial-layers.json` to where you put this folder, copy the file into `~/.config/karabiner/assets/complex_modifications/`, then in Karabiner: Complex Modifications, Add rule, enable **Vial Keyboard Layers**. The trigger is Hyper+K (Ctrl+Opt+Shift+Cmd+K). The file runs `open-layer-map.sh`; for the Mac app, change that to `mac-app/toggle.sh`. |

**Nicest of all: put the hotkey on the keyboard itself**, as a key on one of your layers, so the keyboard can show its own map. In Vial, one key can send Hyper+K in a single press: give it the keycode `HYPR(KC_K)`.

## Privacy

- **It runs entirely in your browser and only reads.** It cannot change anything on your keyboard.
- **Your `.vil` file is never uploaded.** There is no server, and the page makes no network requests of its own. (Served over http, it reads the `notes.json` beside it; nothing else.)
- **What it keeps stays on your machine:** the last layout you loaded and your names, in your browser's local storage.

## What it works with

- **Browsers:** tested in Chrome. It uses nothing browser-specific, so current Safari, Firefox and Edge should work too. **Edit in Vial** opens Vial web, which needs Chrome, Edge or Arc (Safari and Firefox have no WebHID).
- **Mac app** (`hotkey/mac-app/`): macOS 13 or later, and the Xcode command line tools to build it.
- **Chrome hotkey** (`hotkey/open-layer-map.sh`): macOS and Google Chrome.
- **Keyboards:** any Vial keyboard. The Corne (3x6+3, including rev4 with its extra inner keys) is drawn in its real shape: six columns a half, the outer column drawn even where nothing is mapped on it, and three thumb keys tucked in close under the inner columns in a gentle row. Rev4's extra inner keys are drawn when something is mapped on them. Other boards show as a plain grid for now.
- **Typing layouts:** what Shift types is shown for US and UK layouts, on a Mac or a PC. Other layouts (German, French and so on) show the US characters.
- **Colours:** every legend colour reaches WCAG AA contrast for small text (4.5 to 1) on the key face, hovered or pressed, in both themes; the tests check it.

## Limitations

<details>
<summary>What it does not do yet</summary>

- **It reads a saved `.vil`, not the keyboard itself.** Change a key in Vial and the map shows the old layout until you save and load the `.vil` again. How reading straight from the keyboard could work is in [docs/reading-from-the-keyboard.md](docs/reading-from-the-keyboard.md).
- **Only the Corne has a drawn shape.** Other boards show as a plain grid. Reading the physical layout from the keyboard's Vial definition would generalise it.
- **Encoders** (`encoder_layout`) are not drawn.
- **The hosted page needs internet**, in a tab or as an installed app. It is not cached for offline use. The offline routes are the Mac app and the Chrome hotkey.
- **Your saved layout and names live in one browser**, per site. Another browser, another machine, a private window or clearing site data starts from the example again.
- **Tested in Chrome only.** Safari, Firefox and Edge should work but have not been checked.
- **The offline routes are Mac only.** The Mac app needs macOS 13+; the Chrome hotkey script needs macOS and Google Chrome.

</details>

<details>
<summary>Why Vial web is not embedded in the page</summary>

`vial.rocks` allows framing, and WebHID can be delegated to a frame, but Vial web needs `SharedArrayBuffer`, which a browser only enables when the top-level page is cross-origin isolated (COOP and COEP headers). A local file cannot send headers, so in a frame Vial fails on start. **Edit in Vial** opens it in its own tab instead.

</details>

## Related tools

- **[keymap-drawer](https://github.com/caksoylar/keymap-drawer)** (caksoylar) renders QMK and ZMK keymaps to SVG. It draws each layer as its own keyboard, and the output is a static image. It does not read `.vil` directly.
- **[Vial To Keymap Drawer](https://yal-tools.github.io/vial-to-keymap-drawer/)** (YellowAfterlife) converts `.vil` to keymap-drawer YAML.

Together they make a good image for sharing a layout. This page is for the other job: "what is on this key?", answered in a couple of seconds.

## Files

```
index.html                  the whole app: markup, styles, parser, UI, built-in example layout
WHY.md                      what it is for, and the test it has to pass
layouts/miryoku-11.vil      the example layout
notes.json                  names for what keys do, the defaults
tools/embed.py              copies a .vil and notes.json into index.html as the built-in defaults
test/parse.test.mjs         parser tests against the example layout (node test/parse.test.mjs)
hotkey/open-layer-map.sh    opens the map in its own Chrome window
hotkey/karabiner-vial-layers.json   optional Karabiner rule for a Hyper+K hotkey
hotkey/mac-app/             the map as its own Mac app: build.sh, toggle.sh (for a hotkey)
docs/                       screenshots, and the route for reading from the keyboard
icon.svg, *.png (root)      the app icon: tab, Dock, installed app, iPhone home screen
manifest.webmanifest        the app's name and icon when installed from the live page
```

To change the built-in layout: copy your `.vil` into `layouts/`, then run `python3 tools/embed.py layouts/<file>.vil`.

## Licence

MIT, see [LICENSE](LICENSE).

Vial Keyboard Layers is an independent project, not affiliated with Vial.

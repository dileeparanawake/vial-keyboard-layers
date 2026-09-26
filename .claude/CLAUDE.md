# Vial Layer Map

See every layer of a Vial keyboard layout on one screen, in plain words. A single static
`index.html` — no build step, no server, no dependencies.

## Running it

- **Open `index.html` directly** (double-click, or open from a browser). It loads with a
  built-in example layout.
- **Local server (optional):** `python3 -m http.server` from the repo root, then visit
  `http://localhost:8000`. Serving it over http also lets it read `notes.json` beside it.
- **Tests:** `node test/parse.test.mjs`.

## Project structure

- `index.html` — the whole app: markup, styles, parser, UI, built-in example layout.
- `layouts/` — example `.vil` layout(s).
- `notes.json` — default key names, embedded into `index.html` by `tools/embed.py`.
- `tools/embed.py` — copies a `.vil` and `notes.json` into `index.html` as the built-in defaults.
- `test/parse.test.mjs` — parser and rendering tests against the example layout.
- `hotkey/` — scripts to open the map as its own window via a system hotkey.
- `docs/` — screenshots and technical notes (e.g. reading a layout straight from the keyboard).

To change the built-in example layout: copy a `.vil` into `layouts/`, then run
`python3 tools/embed.py layouts/<file>.vil`.

## Shell commands

Run one shell command per tool call. Don't chain commands with `&&`, `||` or `;`, and don't wrap
several steps in a script to run them as one. Each permission prompt should show one command that
can be read at a glance.

## Git workflow

- **Always ask for user confirmation before making any commit.**
- Use **Conventional Commits** syntax (e.g. `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`).
- **Branches:** `main` holds the released page. Work branches off `main` and merges back through a PR.

## Planning

This repo has issues switched off. Work items, plans and the agent-skill setup live outside it,
and load through a gitignored `CLAUDE.local.md`.

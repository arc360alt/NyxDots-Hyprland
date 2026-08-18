# NyxDots

A Hyprland desktop shell built with [Quickshell](https://quickshell.outfoxxed.me):
a pill-shaped top bar, a "SYS: //MONITOR" CPU/MEM/BAT card, a big clock+date
card, a themed app launcher (tap `SUPER`), and a Settings app for keybinds,
theme colors, and wallpaper — all editable live, no restart required.

Theme colors can either be set manually or generated from your wallpaper
with [matugen](https://github.com/InioX/matugen) (Material You-style
extraction).

**This repo never touches `~/.config/hypr`.** Everything here is
self-contained; try it out with `scripts/test-nested.sh`, which boots a
throwaway Hyprland session in a window on top of your real desktop. Only
wire it into your real config yourself, once you're happy with it.

## Quickstart

```sh
./scripts/install.sh      # installs missing deps (Arch/pacman); safe to skip if you already have them
./scripts/test-nested.sh  # boots NyxDots in a nested Hyprland window
```

Inside the nested session:

- `SUPER` (tap) — app launcher
- `SUPER, I` — settings
- `SUPER SHIFT, Q` — exit the nested session (your real desktop is untouched)
- `SUPER, RETURN` / `B` / `E` — terminal / browser / file manager
- `SUPER, Q` / `F` / `V` — close / fullscreen / floating
- `SUPER, 1..9` — switch workspace, `SUPER SHIFT, 1..9` — move window to workspace

All of the above (except workspace switching) are rebindable from
Settings → Keybinds.

## Layout

```
shell/            Quickshell config (QML)
  shell.qml         entry point
  modules/          Bar (+ popups/), Cards (sysmonitor/clock), Launcher, Settings, Background
  services/         Config, Theme, WallpaperService, SystemStats, Notifications singletons
config/default.json Checked-in defaults, copied to state/config.json on first run
hypr/
  nyxdots.lua       Hyprland config for the nested TEST session only
  keybinds.lua      GENERATED from state/config.json — don't hand-edit
scripts/
  test-nested.sh     boots the nested test session (the main entry point)
  install.sh         installs missing deps, optional standalone symlink
  generate-keybinds.py  state/config.json -> hypr/keybinds.lua
  apply-wallpaper.sh    runs matugen, writes state/colors.json
state/             gitignored — live config.json + generated colors.json
```

## Settings app

Open with `SUPER, I` or the gear icon in the top bar. Three tabs:

- **Keybinds** — click "rebind" then press a key combo to capture it, or
  type a combo directly (`SUPER, RETURN` / `SUPER SHIFT, Q` / `, Print`
  style). Add arbitrary extra shortcuts under "custom keybinds" (name,
  combo, shell command).
- **Theme** — "manual colors" lets you set each color token by hex; "match
  wallpaper" generates the whole palette from your current wallpaper via
  matugen and makes the color fields read-only.
- **Wallpaper** — browse for an image (or paste a path) and hit apply. If
  theme mode is "match wallpaper" this also regenerates the color scheme.

Every change is written to `state/config.json` immediately and applies live
across all open panels — no reload needed.

## Going from "nested test" to "my real desktop"

This repo intentionally never edits `~/.config/hypr`. When you're happy with
NyxDots, wire it in yourself:

Hyprland on this system uses its native Lua config (`hyprland.lua`), same as
your real setup — so this is Lua, not the old `hyprland.conf` style:

1. Autostart the shell: `hl.on("hyprland.start", function() hl.exec_cmd('qs -p "/path/to/NyxDots-Hyprland/shell" --no-duplicate') end)`
   (or symlink `shell/` to `~/.config/quickshell/nyxdots` —
   `scripts/install.sh` can do this for you — and use `qs -c nyxdots`
   instead of `-p ...`).
2. Either `require`/adapt `hypr/keybinds.lua`'s `hl.bind(...)` calls into
   your real config, or hand-port the ones you want. `hypr/nyxdots.lua` is a
   working reference for the `hl.layer_rule({ match = { namespace = ... },
   blur = true })` calls that make the panels blur properly.

## Known limitations

- `lock` defaults to `loginctl lock-session`, which won't visually lock the
  screen unless you also have a lock daemon (e.g. `hyprlock`) bound to
  session-lock. Install one and it'll just work.
- The installer (`scripts/install.sh`) automates Arch/pacman only, since
  that's what ships official `quickshell` and `matugen` packages today.
  Other distros get a printed list of what to install by hand.
- The key-combo recorder in Settings → Keybinds covers common keys (letters,
  digits, arrows, Return/Escape/Tab/Space/Print/Home/End/PageUp/PageDown).
  Anything else falls back to a generic code — type the Hyprland key name
  directly into the field instead if that happens.

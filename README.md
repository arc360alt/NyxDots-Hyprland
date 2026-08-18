# NyxDots

![NyxDots screenshot](assets/screenshot.png)

A Hyprland desktop shell built with Quickshell. It has a floating top bar, a workspace switcher, a clock, weather, and a rofi app launcher. Colors and wallpaper can be set by hand or generated from your wallpaper. Everything is editable from the settings app, no restart needed.

## Install

```sh
git clone https://github.com/arc360alt/NyxDots-Hyprland.git && cd NyxDots-Hyprland && ./scripts/install.sh
```

The script installs missing packages on Arch, sets up the config, and can add NyxDots as its own login session so it never touches your current setup.

<details>
<summary>Manual install</summary>

1. Install these packages: hyprland, quickshell, matugen, rofi, python, foot, grim, slurp, and a nerd font such as JetBrainsMono Nerd Font.
2. Clone this repo.
3. Run `python3 scripts/generate-keybinds.py` and `python3 scripts/generate-rofi-theme.py` from the repo root.
4. Try it with `./scripts/test-nested.sh`, which opens NyxDots in a nested Hyprland window on top of your current desktop. Your real config is never touched.
5. To use it as a real login session, add a new file in `/usr/share/wayland-sessions/` with `Exec=env NYXDOTS_SHELL_DIR=/path/to/repo/shell Hyprland -c /path/to/repo/hypr/nyxdots.lua`, then pick it at your login screen.

</details>

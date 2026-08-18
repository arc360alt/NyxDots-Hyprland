#!/usr/bin/env python3
"""Renders rofi/nyxdots.rasi.template into state/rofi-theme.rasi using the
same colors the Quickshell shell itself uses (see shell/services/Theme.qml):
state/config.json's theme.colors normally, but state/colors.json (matugen's
wallpaper-derived palette) takes priority whenever theme.mode is "wallpaper"
and that file exists. Run this after any theme edit (the Settings app does
this automatically) and before showing the launcher.
"""
import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
STATE_CONFIG = REPO_ROOT / "state" / "config.json"
GENERATED_COLORS = REPO_ROOT / "state" / "colors.json"
TEMPLATE = REPO_ROOT / "rofi" / "nyxdots.rasi.template"
OUT_FILE = REPO_ROOT / "state" / "rofi-theme.rasi"
FONT_FAMILY = "JetBrainsMono Nerd Font"

DEFAULT_COLORS = {
    "background": "#0a0f0f",
    "surface": "#131b1aE6",
    "surfaceHigh": "#1d2827E6",
    "primary": "#9bd0cc",
    "text": "#dce8e6",
    "muted": "#a2adac",
    "accent": "#9bd0cc",
    "danger": "#e2746c",
    "outline": "#3f4a49",
}


def resolve_colors():
    colors = dict(DEFAULT_COLORS)
    theme = {}
    if STATE_CONFIG.exists():
        try:
            theme = json.loads(STATE_CONFIG.read_text()).get("theme", {})
        except json.JSONDecodeError:
            theme = {}
    colors.update(theme.get("colors", {}) or {})

    if theme.get("mode") == "wallpaper" and GENERATED_COLORS.exists():
        try:
            generated = json.loads(GENERATED_COLORS.read_text())
            for key in colors:
                if generated.get(key):
                    colors[key] = generated[key]
        except (json.JSONDecodeError, OSError):
            pass

    return colors


def main():
    colors = resolve_colors()
    rendered = TEMPLATE.read_text()
    rendered = rendered.replace("{{font}}", FONT_FAMILY)
    for key, value in colors.items():
        rendered = rendered.replace("{{" + key + "}}", value)

    OUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    OUT_FILE.write_text(rendered)
    print(f"wrote {OUT_FILE}")


if __name__ == "__main__":
    sys.exit(main())

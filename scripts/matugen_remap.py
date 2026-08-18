#!/usr/bin/env python3
"""Reads matugen's `-j hex` JSON (stdin) and remaps its Material You role
names onto NyxDots' compact theme token set (stdout)."""
import json
import sys

ROLE_MAP = {
    "background": "background",
    "surface_container": "surface",
    "surface_container_high": "surfaceHigh",
    "primary": "primary",
    "on_background": "text",
    "on_surface_variant": "muted",
    "primary_alt": "accent",
    "error": "danger",
    "outline": "outline",
}

TRANSLUCENT = {"surface", "surfaceHigh"}


def role_color(colors, role, mode):
    entry = colors.get(role)
    if entry is None:
        return None
    variant = entry.get(mode) or entry.get("default")
    return variant["color"] if variant else None


def main():
    raw = json.load(sys.stdin)
    colors = raw["colors"]
    mode = "dark"

    out = {}
    for matugen_role, token in ROLE_MAP.items():
        source_role = "primary" if matugen_role == "primary_alt" else matugen_role
        color = role_color(colors, source_role, mode)
        if color is None:
            continue
        if token in TRANSLUCENT:
            color += "E6"
        out[token] = color

    json.dump(out, sys.stdout, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()

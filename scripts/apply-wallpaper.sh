#!/usr/bin/env bash
# Regenerates state/colors.json from a wallpaper image via matugen.
# Called by the Settings app's Wallpaper page whenever theme.mode == "wallpaper".
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WALLPAPER="${1:?usage: apply-wallpaper.sh <image-path>}"

if [ ! -f "$WALLPAPER" ]; then
    echo "apply-wallpaper: no such file: $WALLPAPER" >&2
    exit 1
fi

mkdir -p "$REPO_ROOT/state"

matugen image "$WALLPAPER" -m dark -j hex --dry-run -q --prefer saturation \
    | python3 "$REPO_ROOT/scripts/matugen_remap.py" \
    > "$REPO_ROOT/state/colors.json"

echo "nyxdots: wrote $REPO_ROOT/state/colors.json from $WALLPAPER"

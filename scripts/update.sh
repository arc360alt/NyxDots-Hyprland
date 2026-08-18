#!/usr/bin/env bash
# Updates NyxDots to a specific release tag: fetches it, force-checks it
# out (so it's a clean replace of every tracked file, not a merge),
# regenerates derived config, records the new version, and restarts the
# running shell.
#
# Invoked by UpdateService.qml (shell/services/UpdateService.qml) via
# Quickshell.execDetached, since this script kills the very process that
# started it as its last step and has to survive that.
#
# state/ is gitignored, so your live config.json, colors.json, and
# rofi-theme.rasi are never touched by the checkout itself.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAG="${1:?usage: update.sh <tag>}"

cd "$REPO_ROOT"

git fetch --tags origin
git checkout --force "$TAG"

python3 scripts/generate-keybinds.py
python3 scripts/generate-rofi-theme.py

echo "$TAG" > state/version.txt

pkill -f "qs -p $REPO_ROOT/shell" 2>/dev/null || true
sleep 1
setsid nohup qs -p "$REPO_ROOT/shell" --no-duplicate >/dev/null 2>&1 &
disown

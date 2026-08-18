#!/usr/bin/env bash
# Boots NyxDots in a throwaway, nested Hyprland session running inside a
# window on your current desktop. Your real ~/.config/hypr setup is never
# read or written by this script — it launches a completely separate
# Hyprland instance (its own instance signature, its own socket) using only
# hypr/nyxdots.lua from this repo.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "${WAYLAND_DISPLAY:-}" ]; then
    echo "nyxdots: no WAYLAND_DISPLAY detected." >&2
    echo "  Run this from inside an existing Wayland session (e.g. your current" >&2
    echo "  Hyprland login) so Hyprland can nest itself in a window." >&2
    exit 1
fi

for bin in Hyprland qs matugen python3 rofi; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "nyxdots: missing dependency '$bin'. Run scripts/install.sh first." >&2
        exit 1
    fi
done

echo "nyxdots: regenerating hypr/keybinds.lua from state/config.json..."
python3 "$REPO_ROOT/scripts/generate-keybinds.py"

echo "nyxdots: regenerating the rofi launcher theme from state/config.json..."
python3 "$REPO_ROOT/scripts/generate-rofi-theme.py"

export NYXDOTS_SHELL_DIR="$REPO_ROOT/shell"

echo
echo "nyxdots: launching nested test session."
echo "  - your real ~/.config/hypr is untouched"
echo "  - press SUPER + SHIFT + Q inside the nested window to exit it"
echo "  - press SUPER (tap) to open the app launcher"
echo

# Hyprland's own socket auto-selection collides with the host session's if
# run in the same XDG_RUNTIME_DIR (both want "wayland-1"). Give the nested
# instance an isolated runtime dir that only exposes the host's socket
# under a different name, purely so the wlroots backend can still find it
# to nest inside a window.
NESTED_RUNTIME_DIR="$(mktemp -d)"
HYPR_PID=""
cleanup() {
    [ -n "$HYPR_PID" ] && kill "$HYPR_PID" 2>/dev/null
    rm -rf "$NESTED_RUNTIME_DIR"
}
trap cleanup EXIT INT TERM

ln -s "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" "$NESTED_RUNTIME_DIR/host-wayland"

# PipeWire clients (used by the volume popup) look for their socket at
# $XDG_RUNTIME_DIR/pipewire-0 by default. Since XDG_RUNTIME_DIR is about to
# be replaced below (same reason as the Wayland socket above), that would
# silently break audio inside the nested session — symlink the real sockets
# through so PipeWire still resolves normally. D-Bus doesn't need the same
# treatment: DBUS_SESSION_BUS_ADDRESS is an absolute path set once at login,
# not derived from XDG_RUNTIME_DIR, so it passes through untouched already.
for sock in pipewire-0 pipewire-0-manager; do
    if [ -S "$XDG_RUNTIME_DIR/$sock" ]; then
        ln -s "$XDG_RUNTIME_DIR/$sock" "$NESTED_RUNTIME_DIR/$sock"
    fi
done

export XDG_RUNTIME_DIR="$NESTED_RUNTIME_DIR"
export WAYLAND_DISPLAY="host-wayland"

Hyprland -c "$REPO_ROOT/hypr/nyxdots.lua" &
HYPR_PID=$!
wait "$HYPR_PID"

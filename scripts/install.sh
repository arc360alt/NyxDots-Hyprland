#!/usr/bin/env bash
# NyxDots installer — checks for Hyprland + the shell's dependencies and
# installs whatever's missing (Arch/pacman only for now, since that's what
# quickshell and matugen ship official packages for). Never touches your
# existing ~/.config/hypr; the optional standalone symlink step below is the
# only thing that writes outside this repo, and it always asks first.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSUME_YES=0

for arg in "$@"; do
    case "$arg" in
        -y|--yes) ASSUME_YES=1 ;;
        -h|--help)
            echo "usage: $0 [-y|--yes]"
            echo "  -y, --yes   don't prompt; install required + recommended packages"
            exit 0
            ;;
    esac
done

confirm() {
    local prompt="$1"
    if [ "$ASSUME_YES" -eq 1 ]; then return 0; fi
    read -r -p "$prompt [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

if ! command -v pacman >/dev/null 2>&1; then
    cat >&2 <<'EOF'
nyxdots: this installer only automates Arch (pacman) systems.

On other distros, install these yourself and re-run scripts/test-nested.sh:
  - Hyprland
  - Quickshell (https://quickshell.outfoxxed.me)
  - matugen (https://github.com/InioX/matugen)
  - rofi, built with Wayland/layer-shell support (rofi 1.7.4+ or rofi-wayland)
  - Python 3
  - foot, grim, slurp
  - a Nerd Font (e.g. JetBrainsMono Nerd Font)
EOF
    exit 1
fi

# name in pacman -> package to install
# rofi here is the Wayland-native build (Arch's official package provides
# rofi-wayland) — it's the app launcher, themed via rofi/nyxdots.rasi.template.
REQUIRED_PKGS=(hyprland quickshell matugen rofi python foot grim slurp ttf-jetbrains-mono-nerd)
RECOMMENDED_PKGS=(thunar firefox pavucontrol blueman networkmanager upower)

missing() {
    local pkg
    for pkg in "$@"; do
        pacman -Qq "$pkg" >/dev/null 2>&1 || echo "$pkg"
    done
}

missing_required=($(missing "${REQUIRED_PKGS[@]}"))
missing_recommended=($(missing "${RECOMMENDED_PKGS[@]}"))

if [ "${#missing_required[@]}" -eq 0 ]; then
    echo "nyxdots: all required packages are already installed."
else
    echo "nyxdots: missing required packages: ${missing_required[*]}"
    if confirm "Install these with sudo pacman -S --needed?"; then
        sudo pacman -S --needed "${missing_required[@]}"
    else
        echo "nyxdots: skipping required packages — NyxDots will not run without them." >&2
    fi
fi

if [ "${#missing_recommended[@]}" -gt 0 ]; then
    echo "nyxdots: missing recommended packages (browser/files/audio/bluetooth/network/power): ${missing_recommended[*]}"
    if confirm "Install these too?"; then
        sudo pacman -S --needed "${missing_recommended[@]}"
    fi
fi

echo
echo "nyxdots: seeding state/config.json and generating hypr/keybinds.lua..."
python3 "$REPO_ROOT/scripts/generate-keybinds.py"

echo "nyxdots: generating the rofi launcher theme..."
python3 "$REPO_ROOT/scripts/generate-rofi-theme.py"

echo
if confirm "Try NyxDots now in a nested test session (your real Hyprland config is untouched)?"; then
    exec "$REPO_ROOT/scripts/test-nested.sh"
fi

QS_TARGET="$HOME/.config/quickshell/nyxdots"
echo
if [ -e "$QS_TARGET" ]; then
    echo "nyxdots: $QS_TARGET already exists, leaving it alone."
else
    if confirm "Symlink $QS_TARGET -> $REPO_ROOT/shell so 'qs -c nyxdots' works standalone?"; then
        mkdir -p "$HOME/.config/quickshell"
        ln -s "$REPO_ROOT/shell" "$QS_TARGET"
        echo "nyxdots: linked. Run with: qs -c nyxdots"
    fi
fi

cat <<EOF

nyxdots: setup done. From here:
  - test in a nested Hyprland window:  ./scripts/test-nested.sh
  - once you're happy, wire NyxDots into your real Hyprland config yourself
    (this installer and its scripts never touch ~/.config/hypr) — add
    something like 'exec-once = qs -p $REPO_ROOT/shell' to your config.
EOF

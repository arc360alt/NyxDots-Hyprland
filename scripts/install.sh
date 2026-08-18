#!/usr/bin/env bash
# NyxDots installer — checks for Hyprland + the shell's dependencies,
# installs whatever's missing (Arch/pacman only for now, since that's what
# quickshell and matugen ship official packages for), and optionally sets
# up a way to actually run it.
#
# Nothing here touches your existing ~/.config/hypr. The only thing this
# script can write outside this repo is a *new*, separate login session
# entry (a .desktop file under /usr/share/wayland-sessions/) so you can
# pick "NyxDots" at your login screen alongside whatever you already use —
# and it only does that with your explicit yes, showing you exactly what
# will be written first.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSUME_YES=0

for arg in "$@"; do
    case "$arg" in
        -y|--yes) ASSUME_YES=1 ;;
        -h|--help)
            echo "usage: $0 [-y|--yes]"
            echo "  -y, --yes   don't prompt; install required + recommended packages"
            echo "              (still asks before touching anything outside this repo)"
            exit 0
            ;;
    esac
done

# ---- output helpers ------------------------------------------------------

if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    C_BOLD="$(tput bold)"; C_DIM="$(tput dim)"; C_RESET="$(tput sgr0)"
    C_CYAN="$(tput setaf 6)"; C_GREEN="$(tput setaf 2)"
    C_YELLOW="$(tput setaf 3)"; C_RED="$(tput setaf 1)"
else
    C_BOLD=""; C_DIM=""; C_RESET=""; C_CYAN=""; C_GREEN=""; C_YELLOW=""; C_RED=""
fi

STEP_NUM=0
step() {
    STEP_NUM=$((STEP_NUM + 1))
    echo
    echo "${C_CYAN}${C_BOLD}[${STEP_NUM}] $1${C_RESET}"
}
ok()   { echo "  ${C_GREEN}✓${C_RESET} $1"; }
info() { echo "  ${C_DIM}$1${C_RESET}"; }
warn() { echo "  ${C_YELLOW}!${C_RESET} $1"; }
err()  { echo "  ${C_RED}✗${C_RESET} $1" >&2; }

confirm() {
    local prompt="$1"
    if [ "$ASSUME_YES" -eq 1 ]; then return 0; fi
    read -r -p "  ${C_YELLOW}?${C_RESET} $prompt [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

cat <<EOF
${C_CYAN}${C_BOLD}
 ███╗   ██╗██╗   ██╗██╗  ██╗██████╗  ██████╗ ████████╗███████╗
 ████╗  ██║╚██╗ ██╔╝╚██╗██╔╝██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
 ██╔██╗ ██║ ╚████╔╝  ╚███╔╝ ██║  ██║██║   ██║   ██║   ███████╗
 ██║╚██╗██║  ╚██╔╝   ██╔██╗ ██║  ██║██║   ██║   ██║   ╚════██║
 ██║ ╚████║   ██║   ██╔╝ ██╗██████╔╝╚██████╔╝   ██║   ███████║
 ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
${C_RESET}${C_DIM} a Quickshell + Hyprland desktop shell — installer${C_RESET}
EOF

# ---- 1. dependencies ------------------------------------------------------

step "Checking dependencies"

if ! command -v pacman >/dev/null 2>&1; then
    err "this installer only automates Arch (pacman) systems."
    cat >&2 <<EOF

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
    ok "all required packages are already installed."
else
    warn "missing required packages: ${missing_required[*]}"
    if confirm "Install these with sudo pacman -S --needed?"; then
        sudo pacman -S --needed "${missing_required[@]}"
        ok "required packages installed."
    else
        err "skipping required packages — NyxDots will not run without them."
    fi
fi

if [ "${#missing_recommended[@]}" -gt 0 ]; then
    echo
    info "missing recommended packages (browser/files/audio/bluetooth/network/power):"
    info "  ${missing_recommended[*]}"
    if confirm "Install these too?"; then
        sudo pacman -S --needed "${missing_recommended[@]}"
        ok "recommended packages installed."
    fi
fi

# ---- 2. config / theme generation -----------------------------------------

step "Generating config"

python3 "$REPO_ROOT/scripts/generate-keybinds.py" >/dev/null
ok "seeded state/config.json, wrote hypr/keybinds.lua"

python3 "$REPO_ROOT/scripts/generate-rofi-theme.py" >/dev/null
ok "wrote the rofi launcher theme (state/rofi-theme.rasi)"

REPO_SLUG="arc360alt/NyxDots-Hyprland"
LATEST_TAG="$(curl -s -m 10 "https://api.github.com/repos/$REPO_SLUG/releases/latest" \
    | python3 -c "import json,sys; print(json.load(sys.stdin).get('tag_name',''))" 2>/dev/null || true)"
mkdir -p "$REPO_ROOT/state"
if [ -n "$LATEST_TAG" ]; then
    echo "$LATEST_TAG" > "$REPO_ROOT/state/version.txt"
    ok "recorded installed version: $LATEST_TAG"
else
    echo "unreleased" > "$REPO_ROOT/state/version.txt"
    info "no published releases found yet — installed version set to \"unreleased\""
fi

# ---- 3. try it now ----------------------------------------------------

step "Try it"

if confirm "Launch NyxDots now in a nested test window (your real Hyprland config is untouched)?"; then
    exec "$REPO_ROOT/scripts/test-nested.sh"
fi

# ---- 4. real login session (opt-in, additive only) -------------------------

step "Set up a real login session (optional)"

SESSION_FILE="/usr/share/wayland-sessions/nyxdots.desktop"

if [ -d /usr/share/wayland-sessions ]; then
    if [ -e "$SESSION_FILE" ]; then
        info "$SESSION_FILE already exists."
        if confirm "Overwrite it (e.g. this repo moved)?"; then
            REWRITE_SESSION=1
        else
            REWRITE_SESSION=0
        fi
    else
        cat <<EOF

  This adds a ${C_BOLD}new, separate${C_RESET} entry to your login screen's session
  picker — it does ${C_BOLD}not${C_RESET} touch ~/.config/hypr or whatever desktop you use
  today. Pick "NyxDots" at login to try it for real; pick your usual session
  to go back. Nothing about your current setup changes either way.

  This will write (with sudo):
    ${C_DIM}$SESSION_FILE${C_RESET}
EOF
        if confirm "Add the \"NyxDots\" login session?"; then
            REWRITE_SESSION=1
        else
            REWRITE_SESSION=0
        fi
    fi

    if [ "${REWRITE_SESSION:-0}" -eq 1 ]; then
        sudo tee "$SESSION_FILE" >/dev/null <<EOF
[Desktop Entry]
Name=NyxDots
Comment=Hyprland + Quickshell desktop shell (NyxDots)
Exec=env NYXDOTS_SHELL_DIR=$REPO_ROOT/shell Hyprland -c $REPO_ROOT/hypr/nyxdots.lua
Type=Application
DesktopNames=Hyprland
EOF
        ok "wrote $SESSION_FILE — pick \"NyxDots\" from your login screen's session menu."
        info "To remove it later: sudo rm $SESSION_FILE"
    else
        info "skipped — nothing written."
    fi
else
    info "no /usr/share/wayland-sessions found (no Wayland-aware login manager detected)."
    info "skipping the login session entry — you can still run NyxDots via test-nested.sh"
    info "or the standalone quickshell command below."
fi

# ---- 5. standalone quickshell symlink (optional) ---------------------------

step "Standalone quickshell command (optional)"

QS_TARGET="$HOME/.config/quickshell/nyxdots"
if [ -e "$QS_TARGET" ]; then
    info "$QS_TARGET already exists, leaving it alone."
else
    if confirm "Symlink $QS_TARGET -> $REPO_ROOT/shell so 'qs -c nyxdots' works standalone?"; then
        mkdir -p "$HOME/.config/quickshell"
        ln -s "$REPO_ROOT/shell" "$QS_TARGET"
        ok "linked. Run with: qs -c nyxdots"
    fi
fi

# ---- done -------------------------------------------------------------

echo
echo "${C_GREEN}${C_BOLD}nyxdots: setup done.${C_RESET}"
cat <<EOF

  Ways to run it, in order of how real they are:
    - nested test window:  ./scripts/test-nested.sh
    - login screen:         pick "NyxDots" if you set that up above
    - standalone:           qs -c nyxdots  (if you symlinked it above)

  Edit keybinds, theme, wallpaper, and weather location from inside NyxDots
  itself — click the gear icon in the bar, or SUPER + I.
EOF

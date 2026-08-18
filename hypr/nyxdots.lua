-- NyxDots — standalone Hyprland config used ONLY by the nested test session
-- (scripts/test-nested.sh). This file is never sourced by your real
-- ~/.config/hypr setup and nothing in this repo touches that config.
--
-- Uses Hyprland's native Lua config API (hl.*) — see
-- https://wiki.hypr.land/Configuring/Start/

-- Monitor scale comes from state/config.json (Settings -> Display) and is
-- emitted by hl.monitor(...) at the top of the generated hypr/keybinds.lua,
-- required at the bottom of this file.

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = "rgba(9bd0ccee)",
            inactive_border = "rgba(3f4a4966)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,
        blur = {
            enabled = true,
            size = 8,
            passes = 2,
        },
        shadow = {
            enabled = true,
            range = 12,
        },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },

    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1,
        -- Without this, clicking any nyxdots surface while a different
        -- window is focused "spends" the first click on refocus and only
        -- the second click actually reaches the panel.
        mouse_refocus = false,
        touchpad = { natural_scroll = true },
    },
})

-- Blur/transparency for the shell's own layer-shell surfaces.
for _, ns in ipairs({
    "nyxdots-bar",
    "nyxdots-settings", "nyxdots-power-menu",
    "nyxdots-volume", "nyxdots-bluetooth", "nyxdots-network", "nyxdots-notifications",
    "nyxdots-weather-popup",
}) do
    hl.layer_rule({
        name = "blur-" .. ns,
        match = { namespace = "^" .. ns .. "$" },
        blur = true,
    })
end

-- The launcher is rofi now (rofi/nyxdots.rasi.template, generated into
-- state/rofi-theme.rasi by scripts/generate-rofi-theme.py), not a Quickshell
-- surface. Arch's rofi package is the Wayland-native build (provides
-- rofi-wayland) and uses "rofi" as its layer-shell namespace.
hl.layer_rule({
    name = "blur-rofi",
    match = { namespace = "^rofi$" },
    blur = true,
})

-- Escape hatch for the nested test session — the host session is untouched.
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())

-- NYXDOTS_SHELL_DIR is exported by scripts/test-nested.sh before launch.
hl.on("hyprland.start", function()
    hl.exec_cmd('qs -p "' .. os.getenv("NYXDOTS_SHELL_DIR") .. '" --no-duplicate')
end)

-- Generated from state/config.json by scripts/generate-keybinds.py.
require("keybinds")

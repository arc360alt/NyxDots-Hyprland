pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string repoRoot: Quickshell.shellDir + "/.."
    readonly property string statePath: repoRoot + "/state/config.json"
    readonly property string defaultConfigPath: repoRoot + "/config/default.json"
    readonly property string keybindsScript: repoRoot + "/scripts/generate-keybinds.py"
    readonly property string rofiThemeScript: repoRoot + "/scripts/generate-rofi-theme.py"

    property alias theme: adapter.theme
    property alias keybinds: adapter.keybinds
    property alias customKeybinds: adapter.customKeybinds
    property alias display: adapter.display
    property alias weather: adapter.weather
    readonly property bool ready: configFile.loaded

    // Called by Settings pages after mutating theme/keybinds in place.
    function save() {
        configFile.writeAdapter();
        regenerateKeybinds.exec(["python3", root.keybindsScript]);
        regenerateRofiTheme.exec(["python3", root.rofiThemeScript]);
    }

    function setScale(value) {
        root.display.scale = Math.round(value * 100) / 100;
        root.save();
        // Live-apply immediately; the regenerated Lua config also picks
        // this up on the next launch so it survives a restart.
        applyScale.exec(["hyprctl", "keyword", "monitor", ",preferred,auto," + root.display.scale]);
    }

    function setClockFormat(use24Hour) {
        root.display.use24Hour = use24Hour;
        root.save();
    }

    // Called after WeatherService resolves a location name to coordinates
    // via Open-Meteo's geocoding API. lat/lon of 0/0 with hasLocation false
    // means "no location set" — WeatherService falls back to IP geolocation.
    function setLocation(name, lat, lon) {
        root.weather.location = name;
        root.weather.lat = lat;
        root.weather.lon = lon;
        root.weather.hasLocation = true;
        root.save();
    }

    function clearLocation() {
        root.weather.location = "";
        root.weather.lat = 0;
        root.weather.lon = 0;
        root.weather.hasLocation = false;
        root.save();
    }

    function setUnits(units) {
        root.weather.units = units;
        root.save();
    }

    function addCustomKeybind(bind) {
        const list = root.customKeybinds.slice();
        list.push(bind);
        root.customKeybinds = list;
        root.save();
    }

    function removeCustomKeybind(index) {
        const list = root.customKeybinds.slice();
        list.splice(index, 1);
        root.customKeybinds = list;
        root.save();
    }

    FileView {
        id: configFile
        path: root.statePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) seed.running = true;
        }

        JsonAdapter {
            id: adapter

            property JsonObject theme: JsonObject {
                property string mode: "manual"
                property string wallpaper: ""
                property JsonObject colors: JsonObject {
                    property string background: "#0a0f0f"
                    property string surface: "#131b1aE6"
                    property string surfaceHigh: "#1d2827E6"
                    property string primary: "#9bd0cc"
                    property string text: "#dce8e6"
                    property string muted: "#a2adac"
                    property string accent: "#9bd0cc"
                    property string danger: "#e2746c"
                    property string outline: "#3f4a49"
                }
            }

            property JsonObject keybinds: JsonObject {
                property string terminal: "SUPER, RETURN"
                property string browser: "SUPER, B"
                property string fileExplorer: "SUPER, E"
                property string launcher: "SUPER_L"
                property string settings: "SUPER, I"
                property string close: "SUPER, Q"
                property string fullscreen: "SUPER, F"
                property string floating: "SUPER, V"
                property string screenshot: ", Print"
                property string lock: "SUPER, L"
                property string nextWorkspace: "SUPER, mouse_down"
                property string prevWorkspace: "SUPER, mouse_up"
            }

            property list<var> customKeybinds: []

            property JsonObject display: JsonObject {
                property real scale: 1.0
                property bool use24Hour: false
            }

            property JsonObject weather: JsonObject {
                property bool hasLocation: false
                property string location: ""
                property real lat: 0
                property real lon: 0
                // "metric" (°C, km/h) or "imperial" (°F, mph)
                property string units: "metric"
            }
        }
    }

    Process {
        id: seed
        command: ["sh", "-c",
            "mkdir -p '" + repoRoot + "/state' && cp '" + defaultConfigPath + "' '" + statePath + "'"]
        onExited: configFile.reload()
    }

    Process {
        id: regenerateKeybinds
    }

    Process {
        id: regenerateRofiTheme
    }

    Process {
        id: applyScale
    }
}

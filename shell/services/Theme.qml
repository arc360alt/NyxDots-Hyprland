pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool wallpaperMode: Config.theme.mode === "wallpaper"
    readonly property var generated: wallpaperMode && colorsFile.loaded ? _parsed : null
    property var _parsed: null

    readonly property string background: pick("background")
    readonly property string surface: pick("surface")
    readonly property string surfaceHigh: pick("surfaceHigh")
    readonly property string primary: pick("primary")
    readonly property string text: pick("text")
    readonly property string muted: pick("muted")
    readonly property string accent: pick("accent")
    readonly property string danger: pick("danger")
    readonly property string outline: pick("outline")

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int radius: 18

    function pick(key) {
        if (root.generated && root.generated[key]) return root.generated[key];
        return Config.theme.colors[key];
    }

    FileView {
        id: colorsFile
        path: Config.repoRoot + "/state/colors.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try {
                root._parsed = JSON.parse(colorsFile.text());
            } catch (e) {
                root._parsed = null;
            }
        }
    }
}

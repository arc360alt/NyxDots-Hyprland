pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string current: Config.theme.wallpaper
    readonly property string mode: Config.theme.mode
    property bool applying: false

    function setWallpaper(path) {
        Config.theme.wallpaper = path;
        Config.save();
        if (root.mode === "wallpaper") regenerate();
    }

    function setMode(mode) {
        Config.theme.mode = mode;
        Config.save();
        if (mode === "wallpaper" && Config.theme.wallpaper) regenerate();
    }

    function regenerate() {
        if (!Config.theme.wallpaper) return;
        root.applying = true;
        proc.exec(["bash", Config.repoRoot + "/scripts/apply-wallpaper.sh", Config.theme.wallpaper]);
    }

    Process {
        id: proc
        onExited: root.applying = false
    }
}

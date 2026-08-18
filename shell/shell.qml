import Quickshell
import "modules/Background"
import "modules/Bar"
import "modules/Settings"

ShellRoot {
    readonly property var primaryScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    Wallpaper {}
    Bar {}

    SettingsWindow { anchorScreen: primaryScreen }
}

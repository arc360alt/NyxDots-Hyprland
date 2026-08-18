import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"

Variants {
    model: Quickshell.screens

    WlrLayershell {
        required property var modelData
        screen: modelData
        layer: WlrLayer.Background
        namespace: "nyxdots-wallpaper"
        anchors { top: true; bottom: true; left: true; right: true }
        // The bar/cards reserve their own screen space now (so windows tile
        // around them); without this, that reservation also shrinks the
        // background layer itself, leaving a gap where the wallpaper doesn't
        // reach behind the bar.
        exclusionMode: ExclusionMode.Ignore
        color: Theme.background

        Image {
            anchors.fill: parent
            source: Config.theme.wallpaper.length > 0 ? "file://" + Config.theme.wallpaper : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: source != ""
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../services"
import "../Widgets"
import "pages"

WlrLayershell {
    id: root
    property var anchorScreen: null
    screen: anchorScreen
    visible: false
    layer: WlrLayer.Overlay
    namespace: "nyxdots-settings"
    // OnDemand (what plain `focusable: true` maps to) only grabs focus
    // *after* an initial click per the wlr-layer-shell protocol, which is
    // why the first click on a freshly opened panel used to do nothing.
    // Exclusive grabs it immediately when the panel appears.
    keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    implicitWidth: 700
    implicitHeight: 540
    color: "transparent"

    property string activeTab: "keybinds"

    component TabButton: HoverButton {
        id: tabBtn
        property string label: ""
        property bool active: false
        width: parent ? parent.width : 130
        height: 32
        radius: 8

        Rectangle {
            visible: tabBtn.active
            anchors.fill: parent
            radius: 8
            color: Theme.surfaceHigh
            border.width: 1
            border.color: Theme.primary
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: tabBtn.label
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: tabBtn.active ? Theme.primary : Theme.text
        }
    }

    IpcHandler {
        target: "settings"
        function toggle(): void { root.visible = !root.visible; }
        function show(): void { root.visible = true; }
        function hide(): void { root.visible = false; }
        function openWallpaper(): void {
            root.activeTab = "wallpaper";
            root.visible = true;
        }
    }

    Item {
        anchors.fill: parent
        focus: root.visible
        Keys.onEscapePressed: root.visible = false

        Card {
            anchors.fill: parent
            color: Theme.surface

            Row {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 18

                Column {
                    width: 150
                    height: parent.height
                    spacing: 4

                    Text {
                        text: "nyxdots"
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                        color: Theme.primary
                        bottomPadding: 10
                    }

                    TabButton {
                        label: "keybinds"
                        active: root.activeTab === "keybinds"
                        onClicked: root.activeTab = "keybinds"
                    }
                    TabButton {
                        label: "theme"
                        active: root.activeTab === "theme"
                        onClicked: root.activeTab = "theme"
                    }
                    TabButton {
                        label: "wallpaper"
                        active: root.activeTab === "wallpaper"
                        onClicked: root.activeTab = "wallpaper"
                    }
                    TabButton {
                        label: "general"
                        active: root.activeTab === "general"
                        onClicked: root.activeTab = "general"
                    }
                    TabButton {
                        label: "weather"
                        active: root.activeTab === "weather"
                        onClicked: root.activeTab = "weather"
                    }

                    Item { width: 1; height: 1 }

                    HoverButton {
                        width: parent.width
                        height: 32
                        radius: 8
                        hoverColor: Theme.danger
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "close (esc)"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.muted
                        }
                        onClicked: root.visible = false
                    }
                }

                Rectangle {
                    width: 1
                    height: parent.height
                    color: Theme.outline
                }

                Item {
                    width: parent.width - 150 - 18 - 1
                    height: parent.height

                    KeybindsPage { anchors.fill: parent; visible: root.activeTab === "keybinds" }
                    ThemePage { anchors.fill: parent; visible: root.activeTab === "theme" }
                    WallpaperPage { anchors.fill: parent; visible: root.activeTab === "wallpaper" }
                    GeneralPage { anchors.fill: parent; visible: root.activeTab === "general" }
                    WeatherPage { anchors.fill: parent; visible: root.activeTab === "weather" }
                }
            }
        }
    }
}

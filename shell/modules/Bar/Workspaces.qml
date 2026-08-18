import QtQuick
import Quickshell.Hyprland
import "../../services"

Row {
    id: root
    spacing: 6

    Repeater {
        model: 9

        delegate: Item {
            id: wsItem
            required property int index
            readonly property int wsId: index + 1
            readonly property bool active: Hyprland.focusedWorkspace !== null
                && Hyprland.focusedWorkspace.id === wsId
            width: 24
            height: 24

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: wsItem.active ? Theme.primary : "transparent"
                border.width: wsItem.active ? 0 : 1
                border.color: Theme.outline

                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: wsItem.wsId
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: wsItem.active ? Theme.background : Theme.muted
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                // This system's Hyprland build uses the native Lua config
                // API, and it expects raw hyprctl dispatch calls to be Lua
                // expressions too — the classic "workspace N" string form
                // fails to parse (confirmed directly via hyprctl dispatch).
                onClicked: Hyprland.dispatch("hl.dsp.focus({workspace=" + wsItem.wsId + "})")
            }
        }
    }
}

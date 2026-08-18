import QtQuick
import "../../../services"
import "../../Widgets"
import "../"

Item {
    id: page

    readonly property var actions: [
        { key: "terminal", label: "Open terminal" },
        { key: "browser", label: "Open browser" },
        { key: "fileExplorer", label: "Open file manager" },
        { key: "launcher", label: "Toggle app launcher" },
        { key: "settings", label: "Toggle this settings app" },
        { key: "close", label: "Close focused window" },
        { key: "fullscreen", label: "Toggle fullscreen" },
        { key: "floating", label: "Toggle floating" },
        { key: "screenshot", label: "Screenshot (region)" },
        { key: "lock", label: "Lock session" },
        { key: "nextWorkspace", label: "Next workspace (scroll)" },
        { key: "prevWorkspace", label: "Previous workspace (scroll)" }
    ]

    Flickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            width: parent.width
            spacing: 6

            Repeater {
                model: page.actions
                delegate: KeybindRow {
                    required property var modelData
                    width: column.width
                    actionKey: modelData.key
                    actionLabel: modelData.label
                }
            }

            Text {
                text: "custom keybinds"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.muted
                topPadding: 14
                bottomPadding: 4
            }

            Repeater {
                model: Config.customKeybinds
                delegate: CustomKeybindRow {
                    required property var modelData
                    required property int index
                    width: column.width
                    entryIndex: index
                    entry: modelData
                }
            }

            HoverButton {
                width: column.width
                height: 34
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: "+ add custom keybind"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.primary
                }

                onClicked: Config.addCustomKeybind({ name: "new bind", combo: "SUPER, X", exec: "" })
            }
        }
    }
}

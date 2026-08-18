import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../services"
import "../Widgets"

WlrLayershell {
    id: root
    property var anchorScreen: null
    screen: anchorScreen
    visible: false
    layer: WlrLayer.Overlay
    namespace: "nyxdots-power-menu"
    keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    // Position comes from the triggering bar button (see Bar.qml
    // togglePopup / StatusIcons.localXOf) rather than a fixed screen-edge
    // guess, so the popup actually appears under its button.
    property real anchorX: 0
    property real anchorWidth: 0
    anchors { top: true; left: true }
    margins {
        top: 62
        left: {
            const sw = root.screen ? root.screen.width : 1920;
            const desired = root.anchorX + root.anchorWidth - root.implicitWidth;
            return Math.max(8, Math.min(sw - root.implicitWidth - 8, desired));
        }
    }
    implicitWidth: 190
    implicitHeight: column.implicitHeight + 16
    // -1 (ignore other exclusive zones), not 0 — with 0 this popup gets
    // auto-shifted down by the bar's own exclusiveZone reservation on top
    // of its own margins.top, landing far lower than intended. See
    // WeatherCard.qml's git history / SysMonitorCard.qml for the same bug
    // on the widget cards.
    exclusiveZone: -1
    color: "transparent"

    function close() { root.visible = false; }

    Card {
        id: card
        anchors.fill: parent
        focus: root.visible
        Keys.onEscapePressed: root.close()

        Column {
            id: column
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2

            Row {
                width: parent.width
                Item { width: parent.width - 22; height: 1 }
                CloseButton { onCloseRequested: root.close() }
            }

            Repeater {
                model: [
                    { label: "lock session", glyph: "", cmd: ["loginctl", "lock-session"] },
                    { label: "reboot", glyph: "", cmd: ["systemctl", "reboot"] },
                    { label: "shutdown", glyph: "", cmd: ["systemctl", "poweroff"] },
                    { label: "log out", glyph: "", cmd: null }
                ]

                delegate: HoverButton {
                    id: entry
                    required property var modelData
                    width: column.width
                    height: 32
                    radius: 8

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        IconGlyph { glyph: entry.modelData.glyph; font.pixelSize: 13 }
                        Text {
                            text: entry.modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: Theme.text
                        }
                    }

                    onClicked: {
                        root.close();
                        if (entry.modelData.cmd) Quickshell.execDetached(entry.modelData.cmd);
                        // See Workspaces.qml — this Hyprland build parses
                        // raw dispatch strings as Lua expressions, so the
                        // classic "exit" form silently fails to parse.
                        else Hyprland.dispatch("hl.dsp.exit()");
                    }
                }
            }
        }
    }
}

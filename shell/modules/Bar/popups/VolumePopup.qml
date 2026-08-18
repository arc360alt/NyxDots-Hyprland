import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "../../../services"
import "../../Widgets"

WlrLayershell {
    id: root
    property var anchorScreen: null
    screen: anchorScreen
    visible: false
    layer: WlrLayer.Overlay
    namespace: "nyxdots-volume"
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
    implicitWidth: 260
    implicitHeight: content.implicitHeight + 32
    // -1 (ignore other exclusive zones), not 0 — with 0 this popup gets
    // auto-shifted down by the bar's own exclusiveZone reservation on top
    // of its own margins.top, landing far lower than intended. See
    // WeatherCard.qml's git history / SysMonitorCard.qml for the same bug
    // on the widget cards.
    exclusiveZone: -1
    color: "transparent"

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.ready && sink.audio !== null
    readonly property real volumePct: ready ? sink.audio.volume * 100 : 0

    function close() { root.visible = false; }

    // Track every node, not just the default sink — Pipewire's connection
    // is otherwise lazy and may never populate defaultAudioSink at all.
    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    Card {
        id: card
        anchors.fill: parent
        focus: root.visible
        Keys.onEscapePressed: root.close()

        Column {
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Row {
                width: parent.width
                Text {
                    width: parent.width - 22
                    text: "volume"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.muted
                    anchors.verticalCenter: parent.verticalCenter
                }
                CloseButton { onCloseRequested: root.close() }
            }

            Row {
                width: parent.width
                spacing: 12

                HoverButton {
                    width: 32
                    height: 32
                    radius: 8
                    anchors.verticalCenter: parent.verticalCenter
                    IconGlyph {
                        anchors.centerIn: parent
                        glyph: root.ready && root.sink.audio.muted ? "" : ""
                    }
                    onClicked: if (root.ready) root.sink.audio.muted = !root.sink.audio.muted
                }

                Item {
                    width: parent.width - 32 - 50 - parent.spacing * 2
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: track
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Theme.background
                        border.width: 1
                        border.color: Theme.outline

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            radius: 3
                            color: root.ready && root.sink.audio.muted ? Theme.muted : Theme.primary
                            width: track.width * Math.max(0, Math.min(1, root.volumePct / 100))
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.ready
                        onPressed: mouse => setFromX(mouse.x)
                        onPositionChanged: mouse => { if (pressed) setFromX(mouse.x); }
                        function setFromX(x) {
                            root.sink.audio.volume = Math.max(0, Math.min(1, x / width));
                        }
                    }
                }

                Text {
                    width: 50
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(root.volumePct) + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.text
                }
            }

            Text {
                visible: !root.ready
                text: root.sink === null ? "no default output found" : "connecting..."
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.muted
            }
        }
    }
}

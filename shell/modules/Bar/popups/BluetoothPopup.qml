import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth
import "../../../services"
import "../../Widgets"

WlrLayershell {
    id: root
    property var anchorScreen: null
    screen: anchorScreen
    visible: false
    layer: WlrLayer.Overlay
    namespace: "nyxdots-bluetooth"
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
    implicitWidth: 280
    implicitHeight: Math.min(content.implicitHeight + 32, 420)
    // -1 (ignore other exclusive zones), not 0 — with 0 this popup gets
    // auto-shifted down by the bar's own exclusiveZone reservation on top
    // of its own margins.top, landing far lower than intended. See
    // WeatherCard.qml's git history / SysMonitorCard.qml for the same bug
    // on the widget cards.
    exclusiveZone: -1
    color: "transparent"

    readonly property var adapter: Bluetooth.defaultAdapter

    function close() { root.visible = false; }

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

            Item {
                width: parent.width
                height: 26

                Text {
                    anchors.left: parent.left
                    anchors.right: toggleBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "bluetooth"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.muted
                    elide: Text.ElideRight
                }
                HoverButton {
                    id: toggleBtn
                    width: 56
                    height: 26
                    radius: 13
                    anchors.right: closeBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    hoverColor: Theme.surfaceHigh
                    Rectangle {
                        anchors.fill: parent
                        radius: 13
                        color: root.adapter && root.adapter.enabled ? Theme.primary : Theme.background
                        border.width: 1
                        border.color: Theme.outline
                    }
                    Text {
                        anchors.centerIn: parent
                        text: root.adapter && root.adapter.enabled ? "on" : "off"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: root.adapter && root.adapter.enabled ? Theme.background : Theme.muted
                    }
                    onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
                }
                CloseButton {
                    id: closeBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onCloseRequested: root.close()
                }
            }

            Text {
                visible: !root.adapter || !root.adapter.enabled
                text: root.adapter ? "adapter is off" : "no bluetooth adapter found"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.muted
            }

            Flickable {
                visible: root.adapter && root.adapter.enabled
                width: parent.width
                height: Math.min(deviceList.implicitHeight, 300)
                contentHeight: deviceList.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: deviceList
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: root.adapter ? root.adapter.devices : []

                        delegate: HoverButton {
                            id: entry
                            required property var modelData
                            width: deviceList.width
                            height: 44
                            radius: 8

                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: entry.modelData.connected ? Theme.primary : Theme.outline
                                }

                                Column {
                                    width: parent.width - 18
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        text: entry.modelData.name || entry.modelData.deviceName
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        color: Theme.text
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                    Text {
                                        text: entry.modelData.connected
                                            ? "connected"
                                            : (entry.modelData.paired ? "paired" : "available")
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        color: Theme.muted
                                    }
                                }
                            }

                            onClicked: {
                                if (entry.modelData.connected) entry.modelData.disconnect();
                                else if (entry.modelData.paired) entry.modelData.connect();
                                else entry.modelData.pair();
                            }
                        }
                    }

                    Text {
                        visible: root.adapter && root.adapter.devices.values.length === 0
                        text: "no known devices"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.muted
                    }
                }
            }
        }
    }
}

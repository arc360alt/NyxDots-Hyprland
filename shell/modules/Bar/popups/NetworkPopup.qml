import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Networking
import "../../../services"
import "../../Widgets"

WlrLayershell {
    id: root
    property var anchorScreen: null
    screen: anchorScreen
    visible: false
    layer: WlrLayer.Overlay
    namespace: "nyxdots-network"
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

    readonly property var wifiDevice: {
        for (const d of Networking.devices.values) if (d.type === DeviceType.Wifi) return d;
        return null;
    }
    readonly property var wiredDevice: {
        for (const d of Networking.devices.values) if (d.type === DeviceType.Wired) return d;
        return null;
    }
    readonly property bool usingEthernet: wiredDevice !== null && wiredDevice.connected

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

                IconGlyph {
                    id: netIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: root.usingEthernet ? "\uf1e6" : "\uf1eb"
                }

                Text {
                    anchors.left: netIcon.right
                    anchors.leftMargin: 8
                    anchors.right: toggleBtn.visible ? toggleBtn.left : closeBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.usingEthernet ? "ethernet" : "wi-fi"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.muted
                    elide: Text.ElideRight
                }

                HoverButton {
                    id: toggleBtn
                    visible: !root.usingEthernet
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
                        color: Networking.wifiEnabled ? Theme.primary : Theme.background
                        border.width: 1
                        border.color: Theme.outline
                    }
                    Text {
                        anchors.centerIn: parent
                        text: Networking.wifiEnabled ? "on" : "off"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Networking.wifiEnabled ? Theme.background : Theme.muted
                    }
                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }
                CloseButton {
                    id: closeBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onCloseRequested: root.close()
                }
            }

            // Ethernet: just show connection status, no network picker needed.
            Row {
                visible: root.usingEthernet
                width: parent.width
                spacing: 10

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.primary
                }
                Text {
                    text: (root.wiredDevice ? root.wiredDevice.name : "") + " — connected"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.text
                }
            }

            Text {
                visible: !root.usingEthernet && (!root.wifiDevice || !Networking.wifiEnabled)
                text: Networking.wifiEnabled ? "no wifi adapter found" : "wi-fi is off"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.muted
            }

            Flickable {
                visible: !root.usingEthernet && root.wifiDevice && Networking.wifiEnabled
                width: parent.width
                height: Math.min(networkList.implicitHeight, 300)
                contentHeight: networkList.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: networkList
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: root.wifiDevice ? root.wifiDevice.networks : []

                        delegate: HoverButton {
                            id: entry
                            required property var modelData
                            width: networkList.width
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
                                        text: entry.modelData.name
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        color: Theme.text
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                    Text {
                                        text: entry.modelData.connected
                                            ? "connected"
                                            : (entry.modelData.known ? "saved" : "not saved")
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        color: Theme.muted
                                    }
                                }
                            }

                            onClicked: {
                                if (entry.modelData.connected) entry.modelData.disconnect();
                                else if (entry.modelData.known) entry.modelData.connect();
                            }
                        }
                    }

                    Text {
                        visible: root.wifiDevice && root.wifiDevice.networks.values.length === 0
                        text: "no networks found"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.muted
                    }
                }
            }
        }
    }
}

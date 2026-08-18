import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../services"
import "../../Widgets"

WlrLayershell {
    id: root
    property var anchorScreen: null
    screen: anchorScreen
    visible: false
    layer: WlrLayer.Overlay
    namespace: "nyxdots-notifications"
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
    implicitWidth: 300
    implicitHeight: Math.min(content.implicitHeight + 32, 420)
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
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Item {
                width: parent.width
                height: 24

                Text {
                    anchors.left: parent.left
                    anchors.right: clearBtn.visible ? clearBtn.left : closeBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "notifications"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.muted
                    elide: Text.ElideRight
                }
                HoverButton {
                    id: clearBtn
                    visible: Notifications.tracked.values.length > 0
                    width: 70
                    height: 24
                    radius: 7
                    anchors.right: closeBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: "clear all"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.muted
                    }
                    onClicked: {
                        for (const n of Notifications.tracked.values) n.dismiss();
                    }
                }
                CloseButton {
                    id: closeBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onCloseRequested: root.close()
                }
            }

            Flickable {
                width: parent.width
                height: Math.min(list.implicitHeight, 300)
                contentHeight: list.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: list
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: Notifications.tracked

                        delegate: Rectangle {
                            id: entry
                            required property var modelData
                            width: list.width
                            implicitHeight: entryColumn.implicitHeight + 20
                            radius: 10
                            color: Theme.background
                            border.width: 1
                            border.color: Theme.outline

                            Column {
                                id: entryColumn
                                anchors.left: parent.left
                                anchors.right: dismissBtn.left
                                anchors.top: parent.top
                                anchors.margins: 10
                                spacing: 2

                                Text {
                                    text: entry.modelData.appName || "notification"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    color: Theme.muted
                                }
                                Text {
                                    width: parent.width
                                    text: entry.modelData.summary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    color: Theme.text
                                    wrapMode: Text.WordWrap
                                }
                                Text {
                                    width: parent.width
                                    visible: entry.modelData.body.length > 0
                                    text: entry.modelData.body
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: Theme.muted
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 3
                                    elide: Text.ElideRight
                                }
                            }

                            HoverButton {
                                id: dismissBtn
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 6
                                width: 22
                                height: 22
                                radius: 6
                                hoverColor: Theme.danger
                                IconGlyph { anchors.centerIn: parent; glyph: ""; font.pixelSize: 9 }
                                onClicked: entry.modelData.dismiss()
                            }
                        }
                    }

                    Text {
                        visible: Notifications.tracked.values.length === 0
                        text: "no notifications"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.muted
                    }
                }
            }
        }
    }
}

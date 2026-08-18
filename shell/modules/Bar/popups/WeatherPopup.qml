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
    namespace: "nyxdots-weather-popup"
    keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    // Position comes from the triggering bar widget (see Bar.qml
    // togglePopup / WeatherIndicator.activated) rather than a fixed
    // screen-edge guess, so the popup actually appears under it.
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
    implicitWidth: 360
    implicitHeight: content.implicitHeight + 32
    // -1 (ignore other exclusive zones), not 0 — with 0 this popup gets
    // auto-shifted down by the bar's own exclusiveZone reservation on top
    // of its own margins.top, landing far lower than intended. See
    // WeatherCard.qml's git history / SysMonitorCard.qml for the same bug
    // on the widget cards.
    exclusiveZone: -1
    color: "transparent"

    function close() { root.visible = false; }
    onVisibleChanged: if (visible) WeatherService.refresh();

    Card {
        anchors.fill: parent
        focus: root.visible
        Keys.onEscapePressed: root.close()

        Column {
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Item {
                width: parent.width
                height: 20

                Text {
                    anchors.left: parent.left
                    anchors.right: closeBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: WeatherService.locationName.length > 0 ? WeatherService.locationName : "weather"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.muted
                    elide: Text.ElideRight
                }
                CloseButton {
                    id: closeBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onCloseRequested: root.close()
                }
            }

            Row {
                spacing: 16

                IconGlyph {
                    glyph: WeatherService.glyph
                    font.pixelSize: 36
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: WeatherService.loaded ? (Math.round(WeatherService.temp) + WeatherService.tempUnit) : "--"
                        font.family: Theme.fontFamily
                        font.pixelSize: 26
                        font.bold: true
                        color: Theme.text
                    }
                    Text {
                        text: WeatherService.condition
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.muted
                    }
                }
            }

            Row {
                spacing: 18
                visible: WeatherService.loaded

                Text {
                    text: "feels " + Math.round(WeatherService.feelsLike) + WeatherService.tempUnit
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.muted
                }
                Text {
                    text: "humidity " + Math.round(WeatherService.humidity) + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.muted
                }
                Text {
                    text: "wind " + Math.round(WeatherService.windSpeed) + " " + WeatherService.windUnit
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.muted
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outline
            }

            Row {
                width: parent.width
                spacing: 4

                Repeater {
                    model: WeatherService.daily

                    delegate: Column {
                        required property var modelData
                        width: (content.width - 24) / 7
                        spacing: 4

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDate(new Date(modelData.date), "ddd")
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.muted
                        }
                        IconGlyph {
                            anchors.horizontalCenter: parent.horizontalCenter
                            glyph: modelData.glyph
                            font.pixelSize: 16
                            color: Theme.primary
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(modelData.max) + "°"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.text
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(modelData.min) + "°"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.muted
                        }
                    }
                }
            }

            Text {
                visible: !WeatherService.loaded
                text: "loading forecast..."
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.muted
            }
        }
    }
}

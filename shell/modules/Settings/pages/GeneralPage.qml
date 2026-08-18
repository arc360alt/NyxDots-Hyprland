import QtQuick
import "../../../services"
import "../../Widgets"

Item {
    id: page

    readonly property real minScale: 0.5
    readonly property real maxScale: 2.0
    function ratioFor(v) {
        return Math.max(0, Math.min(1, (v - page.minScale) / (page.maxScale - page.minScale)));
    }

    Flickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            width: parent.width
            spacing: 16

            Text {
                text: "display scale"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.text
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Scales the whole shell (bar, cards, launcher, settings) and Hyprland's own monitor output. Applies immediately and survives a restart."
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.muted
            }

            Row {
                width: parent.width
                spacing: 14

                Item {
                    id: sliderArea
                    width: parent.width - 70
                    height: 32

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
                            color: Theme.primary
                            width: track.width * page.ratioFor(Config.display.scale)
                        }
                    }

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: Theme.primary
                        border.width: 2
                        border.color: Theme.background
                        anchors.verticalCenter: track.verticalCenter
                        x: track.width * page.ratioFor(Config.display.scale) - width / 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: mouse => setFromX(mouse.x)
                        onPositionChanged: mouse => { if (pressed) setFromX(mouse.x); }
                        function setFromX(x) {
                            const t = Math.max(0, Math.min(1, x / width));
                            Config.setScale(page.minScale + t * (page.maxScale - page.minScale));
                        }
                    }
                }

                Text {
                    width: 56
                    anchors.verticalCenter: sliderArea.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(Config.display.scale * 100) + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.text
                }
            }

            HoverButton {
                width: 90
                height: 30
                radius: 8
                Text {
                    anchors.centerIn: parent
                    text: "reset (100%)"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.primary
                }
                onClicked: Config.setScale(1.0)
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outline
            }

            Text {
                text: "clock format"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.text
            }

            Row {
                spacing: 10

                HoverButton {
                    width: 90
                    height: 30
                    radius: 8
                    Rectangle {
                        visible: !Config.display.use24Hour
                        anchors.fill: parent
                        radius: 8
                        color: Theme.surfaceHigh
                        border.width: 1
                        border.color: Theme.primary
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "12-hour"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: !Config.display.use24Hour ? Theme.primary : Theme.text
                    }
                    onClicked: Config.setClockFormat(false)
                }

                HoverButton {
                    width: 90
                    height: 30
                    radius: 8
                    Rectangle {
                        visible: Config.display.use24Hour
                        anchors.fill: parent
                        radius: 8
                        color: Theme.surfaceHigh
                        border.width: 1
                        border.color: Theme.primary
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "24-hour"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Config.display.use24Hour ? Theme.primary : Theme.text
                    }
                    onClicked: Config.setClockFormat(true)
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outline
            }

            Text {
                text: "updates"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.text
            }

            Text {
                text: "installed: " + UpdateService.installedVersion
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.muted
            }

            Text {
                visible: UpdateService.checkedOnce && UpdateService.errorMessage.length === 0
                text: UpdateService.updateAvailable
                    ? "latest: " + UpdateService.latestVersion + " (update available)"
                    : "latest: " + UpdateService.latestVersion + " (up to date)"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: UpdateService.updateAvailable ? Theme.primary : Theme.muted
            }

            Text {
                visible: UpdateService.errorMessage.length > 0
                text: UpdateService.errorMessage
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.danger
            }

            Text {
                visible: UpdateService.updating
                text: "updating, the shell will restart shortly..."
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.primary
            }

            Row {
                spacing: 10

                HoverButton {
                    width: 150
                    height: 30
                    radius: 8
                    enabled: !UpdateService.checking && !UpdateService.updating
                    opacity: enabled ? 1 : 0.5
                    Text {
                        anchors.centerIn: parent
                        text: UpdateService.checking ? "checking..." : "check for updates"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.primary
                    }
                    onClicked: UpdateService.checkForUpdates()
                }

                HoverButton {
                    visible: UpdateService.updateAvailable
                    width: 110
                    height: 30
                    radius: 8
                    enabled: !UpdateService.updating
                    opacity: enabled ? 1 : 0.5
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: Theme.primary
                        opacity: 0.15
                    }
                    Text {
                        anchors.centerIn: parent
                        text: UpdateService.updating ? "updating..." : "update now"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.primary
                    }
                    onClicked: UpdateService.applyUpdate()
                }
            }
        }
    }
}

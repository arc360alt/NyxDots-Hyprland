import QtQuick
import "../../../services"
import "../../Widgets"

Item {
    id: page

    readonly property var tokens: [
        { key: "background", label: "background" },
        { key: "surface", label: "surface" },
        { key: "surfaceHigh", label: "surface (high)" },
        { key: "primary", label: "primary" },
        { key: "text", label: "text" },
        { key: "muted", label: "muted text" },
        { key: "accent", label: "accent" },
        { key: "danger", label: "danger" },
        { key: "outline", label: "outline" }
    ]

    Flickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            width: parent.width
            spacing: 14

            Row {
                spacing: 10

                HoverButton {
                    width: 150
                    height: 34
                    radius: 8
                    hoverColor: Theme.surfaceHigh

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        visible: WallpaperService.mode === "manual"
                        color: Theme.surfaceHigh
                        border.width: 1
                        border.color: Theme.primary
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "manual colors"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.text
                    }
                    onClicked: WallpaperService.setMode("manual")
                }

                HoverButton {
                    width: 150
                    height: 34
                    radius: 8
                    hoverColor: Theme.surfaceHigh

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        visible: WallpaperService.mode === "wallpaper"
                        color: Theme.surfaceHigh
                        border.width: 1
                        border.color: Theme.primary
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "match wallpaper"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.text
                    }
                    onClicked: WallpaperService.setMode("wallpaper")
                }
            }

            Text {
                visible: WallpaperService.mode === "wallpaper"
                width: column.width
                wrapMode: Text.WordWrap
                text: "Colors below are generated from your wallpaper (matugen) and read-only. " +
                      "Pick a wallpaper on the Wallpaper page to regenerate them."
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.muted
            }

            Repeater {
                model: page.tokens
                delegate: Item {
                    required property var modelData
                    width: column.width
                    height: 38

                    Row {
                        anchors.fill: parent
                        spacing: 10

                        Rectangle {
                            width: 22
                            height: 22
                            radius: 6
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme[modelData.key]
                            border.width: 1
                            border.color: Theme.outline
                        }

                        Text {
                            width: 130
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: Theme.text
                        }

                        Rectangle {
                            width: 140
                            height: 30
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.background
                            border.width: 1
                            border.color: Theme.outline

                            TextInput {
                                anchors.fill: parent
                                anchors.margins: 8
                                verticalAlignment: TextInput.AlignVCenter
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: Theme.text
                                readOnly: WallpaperService.mode === "wallpaper"
                                text: Config.theme.colors[modelData.key] || ""
                                onEditingFinished: {
                                    Config.theme.colors[modelData.key] = text;
                                    Config.save();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

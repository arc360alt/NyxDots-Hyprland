import QtQuick
import Qt.labs.platform as Platform
import "../../../services"
import "../../Widgets"

Item {
    id: page

    Platform.FileDialog {
        id: fileDialog
        title: "Choose a wallpaper"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.bmp)"]
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.PicturesLocation)
        onAccepted: pathField.text = fileDialog.file.toString().replace("file://", "")
    }

    Column {
        anchors.fill: parent
        spacing: 14

        Rectangle {
            width: parent.width
            height: 220
            radius: Theme.radius
            color: Theme.background
            border.width: 1
            border.color: Theme.outline
            clip: true

            Image {
                anchors.fill: parent
                source: Config.theme.wallpaper.length > 0 ? "file://" + Config.theme.wallpaper : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: Config.theme.wallpaper.length === 0
                text: "no wallpaper set"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.muted
            }
        }

        Row {
            width: parent.width
            spacing: 8

            Rectangle {
                width: parent.width - browseBtn.width - applyBtn.width - 16
                height: 36
                radius: 8
                color: Theme.background
                border.width: 1
                border.color: Theme.outline

                TextInput {
                    id: pathField
                    anchors.fill: parent
                    anchors.margins: 10
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.text
                    text: Config.theme.wallpaper
                    clip: true
                }
            }

            HoverButton {
                id: browseBtn
                width: 90
                height: 36
                radius: 8
                Text {
                    anchors.centerIn: parent
                    text: "browse..."
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.text
                }
                onClicked: fileDialog.open()
            }

            HoverButton {
                id: applyBtn
                width: 80
                height: 36
                radius: 8
                hoverColor: Theme.primary
                Text {
                    anchors.centerIn: parent
                    text: "apply"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.primary
                }
                onClicked: WallpaperService.setWallpaper(pathField.text)
            }
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: WallpaperService.applying
                ? "generating a matching color scheme..."
                : (WallpaperService.mode === "wallpaper"
                    ? "theme colors are following this wallpaper"
                    : "theme is on manual colors — switch to \"match wallpaper\" on the Theme page to follow this image")
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.muted
        }
    }
}

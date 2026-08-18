import QtQuick
import "../../services"
import "../Widgets"

HoverButton {
    id: root
    radius: 8
    width: content.implicitWidth + 14
    height: 26

    signal activated(real x, real width)

    // Same reasoning as StatusIcons.localXOf: this bar surface's own local
    // coordinates, mapped by Bar.qml into an absolute screen X for the
    // forecast popup.
    onClicked: root.activated(root.mapToItem(null, 0, root.height).x, root.width)

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 6

        IconGlyph {
            glyph: WeatherService.glyph
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: Theme.text
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: WeatherService.loaded ? (Math.round(WeatherService.temp) + WeatherService.tempUnit) : "--"
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.text
        }
    }
}

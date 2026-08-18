import QtQuick
import "../../services"

HoverButton {
    id: root
    width: 22
    height: 22
    radius: 6
    hoverColor: Theme.danger
    signal closeRequested()

    IconGlyph {
        anchors.centerIn: parent
        glyph: ""
        font.pixelSize: 10
    }

    onClicked: root.closeRequested()
}

import QtQuick
import "../../services"

Text {
    property string glyph: ""
    text: glyph
    font.family: Theme.fontFamily
    font.pixelSize: 15
    color: Theme.text
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}

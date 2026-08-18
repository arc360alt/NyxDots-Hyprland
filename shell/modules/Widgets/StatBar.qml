import QtQuick
import "../../services"

Item {
    id: root
    property real value: 0 // 0..100
    property color fillColor: Theme.primary
    implicitHeight: 4

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.background
        border.width: 1
        border.color: Theme.outline
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        radius: height / 2
        color: root.fillColor
        width: parent.width * Math.max(0, Math.min(1, root.value / 100))

        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
    }
}

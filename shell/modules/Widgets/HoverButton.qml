import QtQuick
import "../../services"

Item {
    id: root
    signal clicked()
    property alias containsMouse: mouse.containsMouse
    property real radius: 10
    property color hoverColor: Theme.surfaceHigh

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: mouse.containsMouse ? root.hoverColor : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        // MouseArea accepts wheel events by default even with no onWheel
        // handler, which silently blocks scrolling on any Flickable/ListView
        // underneath (e.g. the launcher results list, built from a column of
        // these). Let wheel events fall through instead.
        onWheel: wheel => { wheel.accepted = false; }
    }
}

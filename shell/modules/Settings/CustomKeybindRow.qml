import QtQuick
import "../../services"
import "../Widgets"

Item {
    id: root
    property int entryIndex: 0
    property var entry: ({})
    height: 38

    function field(key, value) {
        const list = Config.customKeybinds.slice();
        list[root.entryIndex] = Object.assign({}, list[root.entryIndex], { [key]: value });
        Config.customKeybinds = list;
        Config.save();
    }

    Row {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            width: parent.width * 0.28
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
                text: root.entry.name || ""
                onEditingFinished: root.field("name", text)
            }
        }

        Rectangle {
            width: parent.width * 0.22
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
                text: root.entry.combo || ""
                onEditingFinished: root.field("combo", text)
            }
        }

        Rectangle {
            width: parent.width * 0.32
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
                text: root.entry.exec || ""
                onEditingFinished: root.field("exec", text)
            }
        }

        HoverButton {
            width: parent.width * 0.1
            height: 30
            radius: 8
            anchors.verticalCenter: parent.verticalCenter
            hoverColor: Theme.danger

            IconGlyph {
                anchors.centerIn: parent
                glyph: ""
                font.pixelSize: 12
            }

            onClicked: Config.removeCustomKeybind(root.entryIndex)
        }
    }
}

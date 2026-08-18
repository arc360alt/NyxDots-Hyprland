import QtQuick
import "../../services"
import "../Widgets"

Item {
    id: root
    property string actionKey: ""
    property string actionLabel: ""
    property bool recording: false
    height: 38

    readonly property var specialKeys: ({
        16777220: "Return", 16777216: "Escape", 16777217: "Tab",
        16777219: "Backspace", 16777223: "Delete", 16777221: "Enter",
        32: "Space", 16777232: "Home", 16777233: "End",
        16777235: "Up", 16777237: "Down", 16777234: "Left", 16777236: "Right",
        16777238: "PageUp", 16777239: "PageDown", 16777377: "Print"
    })

    Row {
        anchors.fill: parent
        spacing: 10

        Text {
            width: parent.width * 0.42
            anchors.verticalCenter: parent.verticalCenter
            text: root.actionLabel
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.text
            elide: Text.ElideRight
        }

        Rectangle {
            width: parent.width * 0.38
            height: 30
            radius: 8
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.background
            border.width: 1
            border.color: root.recording ? Theme.primary : Theme.outline

            TextInput {
                id: field
                anchors.fill: parent
                anchors.margins: 8
                verticalAlignment: TextInput.AlignVCenter
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.text
                text: Config.keybinds[root.actionKey] || ""
                readOnly: root.recording

                onEditingFinished: {
                    Config.keybinds[root.actionKey] = text;
                    Config.save();
                }

                Keys.onPressed: event => {
                    if (!root.recording) return;
                    if ([Qt.Key_Shift, Qt.Key_Control, Qt.Key_Alt, Qt.Key_Meta].includes(event.key)) {
                        return;
                    }
                    const mods = [];
                    if (event.modifiers & Qt.MetaModifier) mods.push("SUPER");
                    if (event.modifiers & Qt.ControlModifier) mods.push("CTRL");
                    if (event.modifiers & Qt.AltModifier) mods.push("ALT");
                    if (event.modifiers & Qt.ShiftModifier) mods.push("SHIFT");

                    let keyName = root.specialKeys[event.key];
                    if (!keyName) {
                        keyName = (event.text && event.text.trim().length > 0)
                            ? event.text.toUpperCase()
                            : ("code" + event.key);
                    }

                    field.text = mods.length > 0 ? (mods.join(" ") + ", " + keyName) : (", " + keyName);
                    root.recording = false;
                    Config.keybinds[root.actionKey] = field.text;
                    Config.save();
                    event.accepted = true;
                }
            }
        }

        HoverButton {
            width: parent.width * 0.16
            height: 30
            radius: 8
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: root.recording ? "press keys" : "rebind"
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: root.recording ? Theme.primary : Theme.muted
            }

            onClicked: {
                root.recording = true;
                field.forceActiveFocus();
            }
        }
    }
}

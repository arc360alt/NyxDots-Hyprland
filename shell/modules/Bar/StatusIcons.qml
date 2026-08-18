import QtQuick
import Quickshell
import Quickshell.Networking
import "../../services"
import "../Widgets"

Row {
    id: root
    spacing: 2
    signal powerRequested(real x, real width)
    signal settingsRequested()
    signal networkRequested(real x, real width)
    signal volumeRequested(real x, real width)
    signal bluetoothRequested(real x, real width)
    signal notificationsRequested(real x, real width)

    // mapToItem(null, ...) maps within this bar surface's own local
    // coordinate space, which is reliable — unlike a true cross-surface
    // global position, which Wayland deliberately doesn't expose to
    // clients. Bar.qml turns this into an absolute screen X for the popup.
    function localXOf(btn) { return btn.mapToItem(null, 0, btn.height).x; }

    readonly property bool usingEthernet: {
        for (const d of Networking.devices.values) {
            if (d.type === DeviceType.Wired && d.connected) return true;
        }
        return false;
    }

    component StatusButton: HoverButton {
        id: btn
        width: 30
        height: 30
        radius: 8
        property string glyph: ""
        IconGlyph {
            anchors.centerIn: parent
            glyph: btn.glyph
            font.pixelSize: 14
        }
    }

    StatusButton {
        id: settingsBtn
        glyph: ""
        onClicked: root.settingsRequested()
    }
    StatusButton {
        id: networkBtn
        glyph: root.usingEthernet ? "" : ""
        onClicked: root.networkRequested(root.localXOf(networkBtn), networkBtn.width)
    }
    StatusButton {
        id: volumeBtn
        glyph: ""
        onClicked: root.volumeRequested(root.localXOf(volumeBtn), volumeBtn.width)
    }
    StatusButton {
        id: bluetoothBtn
        glyph: ""
        onClicked: root.bluetoothRequested(root.localXOf(bluetoothBtn), bluetoothBtn.width)
    }
    StatusButton {
        id: notificationsBtn
        glyph: ""
        onClicked: root.notificationsRequested(root.localXOf(notificationsBtn), notificationsBtn.width)
    }
    StatusButton {
        id: powerBtn
        glyph: ""
        hoverColor: Theme.danger
        onClicked: root.powerRequested(root.localXOf(powerBtn), powerBtn.width)
    }
}

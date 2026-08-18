import QtQuick
import Quickshell.Io
import "../../services"

HoverButton {
    id: root
    width: 30
    height: 30
    radius: 8
    signal activated()

    property string rawSvg: ""
    readonly property string coloredSvg: rawSvg.length > 0 ? rawSvg.replace("#ffffff", Theme.text) : ""

    FileView {
        id: svgFile
        path: Config.repoRoot + "/shell/assets/arch-logo.svg"
        watchChanges: true
        onLoaded: root.rawSvg = svgFile.text()
        onFileChanged: reload()
    }

    Image {
        anchors.centerIn: parent
        width: 18
        height: 18 * 948 / 1000
        source: root.coloredSvg.length > 0 ? "data:image/svg+xml;utf8," + root.coloredSvg : ""
        sourceSize: Qt.size(72, 68)
        smooth: true
    }

    onClicked: root.activated()
}

import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"
import "../Widgets"
import "popups"

Variants {
    model: Quickshell.screens

    WlrLayershell {
        id: barWindow
        required property var modelData
        screen: modelData
        layer: WlrLayer.Top
        namespace: "nyxdots-bar"
        anchors { top: true }
        margins { top: 14 }
        // Hyprland adds this surface's own margins.top on top of
        // exclusiveZone automatically when computing the reserved region —
        // confirmed via `hyprctl monitors`: with margins.top(14) baked into
        // exclusiveZone too (implicitHeight + 14), the actual reserved zone
        // came out to 72 (14 counted twice) instead of the correct 58.
        exclusiveZone: implicitHeight
        focusable: false
        implicitWidth: pill.implicitWidth
        implicitHeight: pill.implicitHeight
        color: "transparent"

        function closeAllPopups() {
            powerMenu.visible = false;
            volumePopup.visible = false;
            bluetoothPopup.visible = false;
            networkPopup.visible = false;
            notificationsPopup.visible = false;
            weatherPopup.visible = false;
        }

        // localX/width come from StatusIcons.localXOf() — a position within
        // this bar surface's own coordinates. The bar itself is centered by
        // the compositor (anchored to top only, no left/right anchor), so
        // its own global screen offset is derived here and added on, giving
        // the popup a true absolute screen X to anchor against.
        function togglePopup(popup, localX, width) {
            const next = !popup.visible;
            closeAllPopups();
            if (localX !== undefined) {
                const barGlobalX = barWindow.screen ? (barWindow.screen.width - barWindow.implicitWidth) / 2 : 0;
                popup.anchorX = barGlobalX + localX;
                popup.anchorWidth = width;
            }
            popup.visible = next;
        }

        SystemClock {
            id: clock
            enabled: true
            precision: SystemClock.Minutes
        }

        Rectangle {
            id: pill
            implicitWidth: barContent.implicitWidth + 44
            implicitHeight: 44
            radius: height / 2
            color: Theme.surface
            border.width: 1
            border.color: Theme.outline

            Row {
                id: barContent
                anchors.centerIn: parent
                spacing: 24

                ArchLogoButton {
                    anchors.verticalCenter: parent.verticalCenter
                    onActivated: {
                        Quickshell.execDetached(["rofi", "-show", "drun", "-theme", Config.repoRoot + "/state/rofi-theme.rasi"]);
                    }
                }

                Workspaces { anchors.verticalCenter: parent.verticalCenter }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(clock.date, Config.display.use24Hour ? "HH:mm" : "h:mm AP")
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    color: Theme.text
                }

                WeatherIndicator {
                    anchors.verticalCenter: parent.verticalCenter
                    onActivated: (x, width) => barWindow.togglePopup(weatherPopup, x, width)
                }

                StatusIcons {
                    anchors.verticalCenter: parent.verticalCenter
                    onPowerRequested: (x, width) => barWindow.togglePopup(powerMenu, x, width)
                    onSettingsRequested: {
                        barWindow.closeAllPopups();
                        Quickshell.execDetached(["qs", "-p", Config.repoRoot + "/shell", "ipc", "call", "settings", "toggle"]);
                    }
                    onNetworkRequested: (x, width) => barWindow.togglePopup(networkPopup, x, width)
                    onVolumeRequested: (x, width) => barWindow.togglePopup(volumePopup, x, width)
                    onBluetoothRequested: (x, width) => barWindow.togglePopup(bluetoothPopup, x, width)
                    onNotificationsRequested: (x, width) => barWindow.togglePopup(notificationsPopup, x, width)
                }
            }
        }

        PowerMenu {
            id: powerMenu
            anchorScreen: barWindow.modelData
        }
        VolumePopup {
            id: volumePopup
            anchorScreen: barWindow.modelData
        }
        BluetoothPopup {
            id: bluetoothPopup
            anchorScreen: barWindow.modelData
        }
        NetworkPopup {
            id: networkPopup
            anchorScreen: barWindow.modelData
        }
        NotificationsPopup {
            id: notificationsPopup
            anchorScreen: barWindow.modelData
        }
        WeatherPopup {
            id: weatherPopup
            anchorScreen: barWindow.modelData
        }
    }
}

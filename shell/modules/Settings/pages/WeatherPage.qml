import QtQuick
import "../../../services"
import "../../Widgets"

Item {
    id: page

    Flickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            width: parent.width
            spacing: 16

            Text {
                text: "location"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.text
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: Config.weather.hasLocation
                    ? "currently: " + Config.weather.location
                    : "no location set — using your IP's approximate location"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.muted
            }

            Row {
                width: parent.width
                spacing: 10

                Rectangle {
                    id: locationBar
                    width: parent.width - 90
                    height: 34
                    radius: height / 2
                    color: Theme.background
                    border.width: 1
                    border.color: WeatherService.geocodeError ? Theme.danger : Theme.outline

                    TextInput {
                        id: locationField
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.text
                        clip: true

                        Keys.onReturnPressed: page.saveLocation()

                        Text {
                            visible: locationField.text.length === 0
                            text: "city, region, or address..."
                            font: locationField.font
                            color: Theme.muted
                        }
                    }
                }

                HoverButton {
                    width: 80
                    height: 34
                    radius: 8
                    Text {
                        anchors.centerIn: parent
                        text: "save"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.primary
                    }
                    onClicked: page.saveLocation()
                }
            }

            Text {
                visible: WeatherService.geocodeError
                text: "couldn't find that location — try being more specific"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.danger
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outline
            }

            Text {
                text: "units"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.text
            }

            Row {
                spacing: 10

                HoverButton {
                    width: 100
                    height: 30
                    radius: 8
                    Rectangle {
                        visible: Config.weather.units === "metric"
                        anchors.fill: parent
                        radius: 8
                        color: Theme.surfaceHigh
                        border.width: 1
                        border.color: Theme.primary
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "metric (°C)"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Config.weather.units === "metric" ? Theme.primary : Theme.text
                    }
                    onClicked: {
                        Config.setUnits("metric");
                        WeatherService.refresh();
                    }
                }

                HoverButton {
                    width: 100
                    height: 30
                    radius: 8
                    Rectangle {
                        visible: Config.weather.units === "imperial"
                        anchors.fill: parent
                        radius: 8
                        color: Theme.surfaceHigh
                        border.width: 1
                        border.color: Theme.primary
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "imperial (°F)"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Config.weather.units === "imperial" ? Theme.primary : Theme.text
                    }
                    onClicked: {
                        Config.setUnits("imperial");
                        WeatherService.refresh();
                    }
                }
            }
        }
    }

    function saveLocation() {
        if (locationField.text.trim().length === 0) return;
        WeatherService.geocode(locationField.text.trim());
    }
}

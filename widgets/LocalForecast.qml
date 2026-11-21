pragma ComponentBehavior: Bound

import qs.config

import QtQuick
import QtQuick.Controls as Controls
import Quickshell.Io

Item {
    id: root

    implicitHeight: 121

    readonly property string locationName: "Killay"
    readonly property real latitude: 51.61952
    readonly property real longitude: -4.01368
    property bool showHourly: true
    property bool animationsEnabled: true
    property bool loading: false
    readonly property bool available: dailyForecast.count > 0 && hourlyForecast.count > 0
    property string errorMessage: ""

    function refresh(): void {
        if (weatherProcess.running)
            return;
        root.loading = true;
        root.errorMessage = "";
        weatherProcess.running = true;
    }

    function localDate(value): date {
        const parts = value.split(/[-T:]/);
        return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]), Number(parts[3] || 12));
    }

    function consume(payload): void {
        try {
            const response = JSON.parse(payload);
            const daily = response.daily;
            const hourly = response.hourly;
            if (!daily?.time?.length || !hourly?.time?.length)
                throw new Error("Forecast response contained incomplete data");

            dailyForecast.clear();
            for (let index = 0; index < Math.min(5, daily.time.length); index++) {
                dailyForecast.append({
                    "dateValue": root.localDate(daily.time[index]),
                    "weatherCode": Number(daily.weather_code[index]),
                    "high": Math.round(Number(daily.temperature_2m_max[index])),
                    "low": Math.round(Number(daily.temperature_2m_min[index])),
                    "precipitation": Math.round(Number(daily.precipitation_probability_max[index]))
                });
            }

            hourlyForecast.clear();
            for (let index = 0; index < Math.min(6, hourly.time.length); index++) {
                hourlyForecast.append({
                    "dateValue": root.localDate(hourly.time[index]),
                    "weatherCode": Number(hourly.weather_code[index]),
                    "isDay": Number(hourly.is_day[index]) === 1,
                    "temperature": Math.round(Number(hourly.temperature_2m[index])),
                    "precipitation": Math.round(Number(hourly.precipitation_probability[index]))
                });
            }
        } catch (error) {
            root.errorMessage = "Forecast unavailable";
        }
    }

    ListModel { id: dailyForecast }
    ListModel { id: hourlyForecast }

    Process {
        id: weatherProcess
        command: [
            "curl", "--fail", "--silent", "--show-error", "--max-time", "10",
            "https://api.open-meteo.com/v1/forecast?latitude=" + root.latitude
                + "&longitude=" + root.longitude
                + "&hourly=weather_code,temperature_2m,precipitation_probability,is_day"
                + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
                + "&timezone=Europe%2FLondon&forecast_hours=6&forecast_days=5"
        ]
        stdout: SplitParser { onRead: data => root.consume(data) }
        onExited: (exitCode, exitStatus) => {
            root.loading = false;
            if (exitCode !== 0 && !root.available)
                root.errorMessage = "Forecast unavailable";
        }
    }

    Timer {
        interval: 30 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Column {
        anchors.fill: parent
        spacing: 5

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.locationName.toUpperCase() + "  /  FORECAST"
                color: Theme.textMuted
                opacity: 0.76
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.Medium
                font.letterSpacing: 0.7
            }

            Row {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                spacing: 2

                Repeater {
                    model: [
                        { "label": "HOURS", "hourly": true, "width": 50 },
                        { "label": "5 DAYS", "hourly": false, "width": 58 }
                    ]

                    delegate: Controls.AbstractButton {
                        id: modeButton
                        required property var modelData
                        readonly property bool selected: root.showHourly === modelData.hourly
                        width: modelData.width
                        height: 24
                        hoverEnabled: true
                        focusPolicy: Qt.StrongFocus
                        Accessible.name: modelData.hourly ? "Hourly forecast" : "Five day forecast"
                        Accessible.selected: selected
                        onClicked: root.showHourly = modelData.hourly

                        background: Rectangle {
                            radius: 6
                            color: modeButton.selected ? Theme.popupSurfaceRaised
                                : (modeButton.hovered ? Theme.islandSurfaceHover : "transparent")
                            border.width: modeButton.visualFocus || modeButton.selected ? 1 : 0
                            border.color: modeButton.visualFocus ? Theme.borderHover : Theme.borderDefault
                        }
                        contentItem: Text {
                            text: modeButton.modelData.label
                            color: modeButton.selected ? Theme.textPrimary : Theme.textMuted
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: 8
                            font.weight: modeButton.selected ? Font.DemiBold : Font.Normal
                            font.letterSpacing: 0.3
                        }
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                    }
                }
            }
        }

        Row {
            visible: root.available && root.showHourly
            width: parent.width
            height: 92

            Repeater {
                model: hourlyForecast
                delegate: Item {
                    id: hourItem
                    required property date dateValue
                    required property int weatherCode
                    required property bool isDay
                    required property int temperature
                    required property int precipitation
                    width: root.width / 6
                    height: 92

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.locale().toString(hourItem.dateValue, "HH:mm")
                            color: Theme.textMuted
                            opacity: 0.78
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                        }
                        WeatherIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 48
                            height: 48
                            weatherCode: hourItem.weatherCode
                            isDay: hourItem.isDay
                            animate: root.animationsEnabled && root.showHourly
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: hourItem.temperature + "°"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: hourItem.precipitation > 0 ? hourItem.precipitation + "%" : ""
                            color: Theme.textMuted
                            opacity: 0.62
                            font.family: Theme.fontFamily
                            font.pixelSize: 8
                        }
                    }
                }
            }
        }

        Row {
            visible: root.available && !root.showHourly
            width: parent.width
            height: 92

            Repeater {
                model: dailyForecast
                delegate: Item {
                    id: dayItem
                    required property date dateValue
                    required property int weatherCode
                    required property int high
                    required property int low
                    required property int precipitation
                    width: root.width / 5
                    height: 92

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.locale().toString(dayItem.dateValue, "ddd").toUpperCase()
                            color: Theme.textMuted
                            opacity: 0.78
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            font.letterSpacing: 0.4
                        }
                        WeatherIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 48
                            height: 48
                            weatherCode: dayItem.weatherCode
                            isDay: true
                            animate: root.animationsEnabled && !root.showHourly
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 3
                            Text {
                                text: dayItem.high + "°"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: dayItem.low + "°"
                                color: Theme.textMuted
                                opacity: 0.65
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }

        Text {
            visible: !root.available
            width: parent.width
            height: 91
            text: root.loading ? "Loading local forecast…" : root.errorMessage
            color: Theme.textMuted
            opacity: 0.72
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: Theme.fontFamily
            font.pixelSize: 10
        }
    }
}

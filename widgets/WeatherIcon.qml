import qs.config

import QtQuick
import QtQuick.Controls as Controls
import Qt.labs.lottieqt

Item {
    id: root

    required property int weatherCode
    property bool isDay: true
    property bool animate: true
    readonly property string conditionName: conditionLabel(weatherCode)

    implicitWidth: 48
    implicitHeight: 48

    Accessible.name: conditionName
    Accessible.description: "Weather condition"

    function conditionLabel(code): string {
        switch (code) {
        case 0: return "Clear sky";
        case 1: return "Mostly clear";
        case 2: return "Partly cloudy";
        case 3: return "Overcast";
        case 45: return "Fog";
        case 48: return "Freezing fog";
        case 51: return "Light drizzle";
        case 53: return "Drizzle";
        case 55: return "Heavy drizzle";
        case 56: return "Light freezing drizzle";
        case 57: return "Freezing drizzle";
        case 61: return "Light rain";
        case 63: return "Rain";
        case 65: return "Heavy rain";
        case 66: return "Light freezing rain";
        case 67: return "Freezing rain";
        case 71: return "Light snow";
        case 73: return "Snow";
        case 75: return "Heavy snow";
        case 77: return "Snow grains";
        case 80: return "Light rain showers";
        case 81: return "Rain showers";
        case 82: return "Heavy rain showers";
        case 85: return "Light snow showers";
        case 86: return "Heavy snow showers";
        case 95: return "Thunderstorm";
        case 96: return "Thunderstorm with light hail";
        case 99: return "Thunderstorm with heavy hail";
        default: return "Mixed conditions";
        }
    }

    function iconName(): string {
        const suffix = root.isDay ? "day" : "night";
        const code = root.weatherCode;

        if (code === 0)
            return "clear-" + suffix;
        if (code === 1 || code === 2)
            return "partly-cloudy-" + suffix;
        if (code === 3)
            return "overcast";
        if (code === 45 || code === 48)
            return "fog-" + suffix;
        if (code >= 51 && code <= 57)
            return "drizzle";
        if (code === 66 || code === 67)
            return "sleet";
        if ((code >= 61 && code <= 65) || (code >= 80 && code <= 82))
            return "rain";
        if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86))
            return "snow";
        if (code >= 95)
            return "thunderstorms-" + suffix + "-rain";
        return "overcast";
    }

    function syncPlayback(): void {
        if (animation.status !== LottieAnimation.Ready)
            return;

        if (root.animate && !MotionPreferences.reducedMotion)
            animation.play();
        else
            animation.stop();
    }

    onAnimateChanged: syncPlayback()

    Connections {
        target: MotionPreferences
        function onReducedMotionChanged(): void { root.syncPlayback(); }
    }

    Item {
        anchors.fill: parent
        clip: true

        // A real static Meteocons asset is both the reduced-motion presentation
        // and the resilient fallback while Lottie loads or fails to decode.
        Image {
            anchors.fill: parent
            source: Qt.resolvedUrl("../assets/weather/meteocons/" + root.iconName() + ".svg")
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: MotionPreferences.reducedMotion
                || animation.status !== LottieAnimation.Ready
        }

        LottieAnimation {
            id: animation

            anchors.centerIn: parent
            width: 128
            height: 128
            scale: Math.min(parent.width / width, parent.height / height)
            transformOrigin: Item.Center
            source: Qt.resolvedUrl("../assets/weather/meteocons/lottie/" + root.iconName() + ".json")
            loops: LottieAnimation.Infinite
            quality: LottieAnimation.HighQuality
            autoPlay: false
            visible: !MotionPreferences.reducedMotion
                && status === LottieAnimation.Ready

            onStatusChanged: root.syncPlayback()
        }
    }

    HoverHandler {
        id: weatherHover
    }

    Controls.ToolTip.visible: weatherHover.hovered
    Controls.ToolTip.text: root.conditionName
    Controls.ToolTip.delay: 450
}

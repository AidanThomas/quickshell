import qs.config

import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property string name

    property color color: Theme.textPrimary
    property real iconSize: 16
    property point opticalOffset: Qt.point(0, 0)
    property bool unavailable: false

    readonly property var semanticSources: ({
        "action.check": "check-fill-mask.svg",
        "action.dismiss": "x-fill-mask.svg",
        "audio.microphone": "microphone-fill-mask.svg",
        "audio.microphoneMuted": "microphone-slash-fill-mask.svg",
        "audio.muted": "speaker-x-fill-mask.svg",
        "audio.volumeHigh": "speaker-high-fill-mask.svg",
        "audio.volumeLow": "speaker-low-fill-mask.svg",
        "calendar.today": "calendar-fill-mask.svg",
        "device.select": "caret-down-fill-mask.svg",
        "media.next": "skip-forward-fill-mask.svg",
        "media.pause": "pause-fill-mask.svg",
        "media.play": "play-fill-mask.svg",
        "media.previous": "skip-back-fill-mask.svg",
        "navigation.next": "caret-right-fill-mask.svg",
        "navigation.previous": "caret-left-fill-mask.svg",
        "notifications.default": "bell-fill-mask.svg",
        "notifications.muted": "bell-slash-fill-mask.svg",
        "session.power": "power-fill-mask.svg"
    })
    readonly property string assetName: semanticSources[name] ?? ""

    implicitWidth: iconSize
    implicitHeight: iconSize
    opacity: unavailable ? Theme.iconUnavailableOpacity : 1

    Image {
        id: sourceImage

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.opticalOffset.x
        anchors.verticalCenterOffset: root.opticalOffset.y
        width: root.iconSize
        height: root.iconSize
        source: root.assetName.length > 0
            ? Qt.resolvedUrl("../assets/icons/" + root.assetName)
            : ""
        // Qt rasterizes SVG images at sourceSize before applying effects.
        // Supersample once so small filled silhouettes retain crisp edges.
        sourceSize: Qt.size(Math.ceil(root.iconSize * 2), Math.ceil(root.iconSize * 2))
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: false
        cache: false
        layer.enabled: true
        layer.textureSize: Qt.size(Math.ceil(width * 2), Math.ceil(height * 2))
        layer.smooth: true
        layer.effect: MultiEffect {
            colorization: 1
            colorizationColor: root.color
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: MotionPreferences.duration(Theme.motionStateDuration)
            easing.type: Theme.motionStateEasing
        }
    }
}

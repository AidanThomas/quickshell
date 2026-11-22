import qs.config
import qs.components

import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var player

    property real volumeBeforeMute: 1.0

    implicitWidth: 24
    implicitHeight: 120

    Slider {
        id: volumeSlider

        anchors {
            top: parent.top
            bottom: volumeIcon.top
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 6
        }

        width: 16
        orientation: Qt.Vertical
        from: 0.0
        to: 1.0
        value: root.player?.volume ?? 1.0
        enabled: (root.player?.canControl ?? false) && (root.player?.volumeSupported ?? false)
        onMoved: {
            root.player.volume = value;
            if (value > 0)
                root.volumeBeforeMute = value;
        }

        background: Rectangle {
            x: volumeSlider.leftPadding + volumeSlider.availableWidth / 2 - width / 2
            y: volumeSlider.topPadding
            width: 4
            height: volumeSlider.availableHeight
            radius: 2
            color: Theme.borderSubtle

            Rectangle {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                height: parent.height * volumeSlider.position
                radius: parent.radius
                color: Theme.accentCyan
            }
        }

        handle: Rectangle {
            x: volumeSlider.leftPadding + volumeSlider.availableWidth / 2 - width / 2
            y: volumeSlider.topPadding + volumeSlider.visualPosition * (volumeSlider.availableHeight - height)
            width: 10
            height: 10
            radius: width / 2
            color: Theme.accentCyan
            opacity: volumeSlider.hovered || volumeSlider.pressed ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: MotionPreferences.duration(Theme.motionFeedbackDuration)
                    easing.type: Theme.motionFeedbackEasing
                }
            }
        }
    }

    IslandAction {
        id: volumeIcon

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        width: 24
        height: 24
        text: (root.player?.volume ?? 0) === 0 ? "Unmute media" : "Mute media"
        tooltipText: text
        iconSize: 16
        iconName: {
            const volume = root.player?.volume ?? 0;

            if (volume === 0)
                return "audio.muted";

            if (volume < 0.5)
                return "audio.volumeLow";

            return "audio.volumeHigh";
        }

        iconColor: (root.player?.volume ?? 0) === 0 ? Theme.accentAmber : Theme.textMuted
        unavailable: !(root.player?.canControl ?? false) || !(root.player?.volumeSupported ?? false)
        onClicked: {
            if (!root.player)
                return;

            if (root.player.volume > 0) {
                root.volumeBeforeMute = root.player.volume;
                root.player.volume = 0;
            } else {
                root.player.volume = root.volumeBeforeMute;
            }
        }
    }
}

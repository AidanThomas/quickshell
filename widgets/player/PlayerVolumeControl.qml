import qs.config

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
        enabled: root.player?.canControl && root.player?.volumeSupported
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
            color: Theme.surface

            Rectangle {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                height: parent.height * volumeSlider.position
                radius: parent.radius
                color: Theme.text
            }
        }

        handle: Rectangle {
            x: volumeSlider.leftPadding + volumeSlider.availableWidth / 2 - width / 2
            y: volumeSlider.topPadding + volumeSlider.visualPosition * (volumeSlider.availableHeight - height)
            width: 10
            height: 10
            radius: width / 2
            color: Theme.text
            opacity: volumeSlider.hovered || volumeSlider.pressed ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                }
            }
        }
    }

    Text {
        font.family: Theme.fontFamily
        id: volumeIcon

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        text: {
            const volume = root.player?.volume ?? 0;

            if (volume === 0)
                return "󰖁";

            if (volume < 0.5)
                return "󰕿";

            return "󰕾";
        }

        color: Theme.text
        opacity: 0.7

        MouseArea {
            anchors.fill: parent
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
}

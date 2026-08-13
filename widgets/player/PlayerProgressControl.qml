import qs.config

import QtQuick

Column {
    id: root

    required property var player

    property real currentPosition: root.player?.position ?? 0

    width: parent.width

    Timer {
        interval: 1000
        running: root.player?.isPlaying ?? false
        repeat: true
        onTriggered: {
            root.currentPosition = root.player?.position ?? 0;
        }
    }

    Connections {
        target: root.player
        function onTrackChanged() {
            root.currentPosition = root.player?.position ?? 0;
        }
    }

    function seekTo(x) {
        if (!root.player || root.player.length <= 0)
            return;

        const fraction = Math.max(0, Math.min(1, x / progressBar.width));
        const position = fraction * root.player.length;

        root.player.position = position;
        root.currentPosition = position;
    }

    function formatTime(seconds) {
        if (!Number.isFinite(seconds) || seconds < 0)
            return "0:00";

        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = Math.floor(seconds % 60);

        return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`;
    }

    spacing: 4

    Column {
        width: parent.width
        spacing: 4

        Item {
            id: progressBar
            width: parent.width
            height: 8

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 4
                radius: 2
                color: Theme.surface

                Rectangle {
                    id: progress
                    width: {
                        if (!root.player?.lengthSupported || root.player.length <= 0)
                            return 0;

                        return parent.width * (root.currentPosition / root.player.length);
                    }
                    height: parent.height
                    radius: parent.radius
                    color: Theme.text
                }

                Rectangle {
                    id: handle
                    width: 10
                    height: 10
                    radius: width / 2
                    color: Theme.text
                    opacity: progressMouseArea.containsMouse || progressMouseArea.pressed ? 1 : 0
                    anchors.verticalCenter: parent.verticalCenter
                    x: Math.max(0, Math.min(track.width - width, progress.width - width / 2))
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }
            }

            MouseArea {
                id: progressMouseArea
                anchors.fill: parent
                enabled: root.player?.canSeek && root.player?.positionSupported && root.player?.lengthSupported
                hoverEnabled: true

                onPressed: mouse => {
                    root.seekTo(mouse.x);
                }

                onPositionChanged: mouse => {
                    if (pressed)
                        root.seekTo(mouse.x);
                }
            }
        }

        Item {
            width: parent.width
            height: timeLeft.implicitHeight

            Text {
                id: timeLeft
                anchors.left: parent.left
                text: root.formatTime(root.currentPosition)
                color: Theme.text
                opacity: 0.6
            }

            Text {
                anchors.right: parent.right
                text: root.formatTime(root.player?.length ?? 0)
                color: Theme.text
                opacity: 0.6
            }
        }
    }
}

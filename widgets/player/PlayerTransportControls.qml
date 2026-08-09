import qs.config
import QtQuick

Row {
    id: root

    required property var player

    spacing: 4

    Rectangle {
        width: 24
        height: 24
        radius: 6

        color: previousMouse.containsMouse ? Theme.surfaceHover : "transparent"

        Text {
            anchors.centerIn: parent
            text: "󰒮"
            color: Theme.text
            opacity: root.player?.canGoPrevious ? 1.0 : 0.3
        }

        MouseArea {
            id: previousMouse
            hoverEnabled: true
            anchors.fill: parent
            enabled: root.player?.canGoPrevious ?? false
            onClicked: root.player.previous()
        }
    }

    Rectangle {
        width: 24
        height: 24
        radius: 6

        color: playPauseMouse.containsMouse ? Theme.surfaceHover : "transparent"

        Text {
            anchors.centerIn: parent
            text: root.player?.isPlaying ? "󰏤" : "󰐊"
            color: Theme.text
            opacity: root.player?.canTogglePlaying ? 1.0 : 0.3
        }

        MouseArea {
            id: playPauseMouse
            hoverEnabled: true
            anchors.fill: parent
            enabled: root.player?.canTogglePlaying ?? false
            onClicked: root.player.togglePlaying()
        }
    }

    Rectangle {
        width: 24
        height: 24
        radius: 6

        color: nextMouse.containsMouse ? Theme.surfaceHover : "transparent"

        Text {
            anchors.centerIn: parent
            text: "󰒭"
            color: Theme.text
            opacity: root.player?.canGoNext ? 1.0 : 0.3
        }

        MouseArea {
            id: nextMouse
            hoverEnabled: true
            anchors.fill: parent
            enabled: root.player?.canGoNext ?? false
            onClicked: root.player.next()
        }
    }
}

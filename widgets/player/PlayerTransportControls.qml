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

        color: previousMouse.containsMouse ? Theme.islandSurfaceHover : "transparent"

        Text {
            font.family: Theme.iconFontFamily
            anchors.centerIn: parent
            text: "󰒮"
            color: Theme.textPrimary
            opacity: root.player?.canGoPrevious ? 1.0 : 0.3
        }

        MouseArea {
            id: previousMouse
            hoverEnabled: true
            anchors.fill: parent
            enabled: root.player?.canGoPrevious ?? false
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (root.player?.canGoPrevious)
                    root.player.previous();
            }
        }
    }

    Rectangle {
        width: 24
        height: 24
        radius: 6

        color: playPauseMouse.containsMouse ? Theme.islandSurfaceHover : "transparent"

        Text {
            font.family: Theme.iconFontFamily
            anchors.centerIn: parent
            text: root.player?.isPlaying ? "󰏤" : "󰐊"
            color: root.player?.isPlaying ? Theme.accentCyan : Theme.textPrimary
            opacity: root.player?.canTogglePlaying ? 1.0 : 0.3
        }

        MouseArea {
            id: playPauseMouse
            hoverEnabled: true
            anchors.fill: parent
            enabled: root.player?.canTogglePlaying ?? false
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (root.player?.canTogglePlaying)
                    root.player.togglePlaying();
            }
        }
    }

    Rectangle {
        width: 24
        height: 24
        radius: 6

        color: nextMouse.containsMouse ? Theme.islandSurfaceHover : "transparent"

        Text {
            font.family: Theme.iconFontFamily
            anchors.centerIn: parent
            text: "󰒭"
            color: Theme.textPrimary
            opacity: root.player?.canGoNext ? 1.0 : 0.3
        }

        MouseArea {
            id: nextMouse
            hoverEnabled: true
            anchors.fill: parent
            enabled: root.player?.canGoNext ?? false
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (root.player?.canGoNext)
                    root.player.next();
            }
        }
    }
}

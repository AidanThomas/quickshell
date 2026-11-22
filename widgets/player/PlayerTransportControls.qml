import qs.config
import qs.components

import QtQuick

Row {
    id: root

    required property var player

    spacing: 4

    IslandAction {
        width: 24
        height: 24
        text: "Previous track"
        tooltipText: text
        iconName: "media.previous"
        iconSize: 16
        unavailable: !(root.player?.canGoPrevious ?? false)
        onClicked: {
            if (root.player?.canGoPrevious)
                root.player.previous();
        }
    }

    IslandAction {
        width: 24
        height: 24
        text: root.player?.isPlaying ? "Pause" : "Play"
        tooltipText: text
        iconName: root.player?.isPlaying ? "media.pause" : "media.play"
        iconSize: 16
        iconColor: root.player?.isPlaying ? Theme.accentCyan : Theme.textPrimary
        unavailable: !(root.player?.canTogglePlaying ?? false)
        onClicked: {
            if (root.player?.canTogglePlaying)
                root.player.togglePlaying();
        }
    }

    IslandAction {
        width: 24
        height: 24
        text: "Next track"
        tooltipText: text
        iconName: "media.next"
        iconSize: 16
        unavailable: !(root.player?.canGoNext ?? false)
        onClicked: {
            if (root.player?.canGoNext)
                root.player.next();
        }
    }
}

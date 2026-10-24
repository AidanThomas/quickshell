import qs.config
import qs.widgets.player
import QtQuick
import Quickshell.Services.Mpris

Item {
    id: root

    signal popupEscapeDismissed

    visible: root.hasPlayer

    implicitWidth: 280
    implicitHeight: content.implicitHeight

    readonly property var player: Mpris.players.values.find(player => player.identity === "Spotify")
    readonly property bool hasPlayer: root.player !== undefined
    readonly property bool popupOpen: popupWindow.visible
    readonly property bool canTogglePlaying: root.player?.canTogglePlaying ?? false
    readonly property string trackDescription: root.hasPlayer
        ? `${root.player?.trackTitle || "Untitled"} by ${root.player?.trackArtist || "Unknown artist"}`
        : "Media unavailable"

    function togglePopup() {
        popupWindow.visible = !popupWindow.visible;
    }

    function closePopup() {
        popupWindow.visible = false;
    }

    function togglePlaying() {
        if (root.canTogglePlaying)
            root.player.togglePlaying();
    }

    Row {
        id: content
        width: root.width
        spacing: 7

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: root.player?.isPlaying ? 18 : 8
            radius: 1
            color: root.player?.isPlaying ? Theme.accentCyan : Theme.textMuted

            Behavior on height {
                NumberAnimation {
                    duration: Theme.animationState
                    easing.type: Theme.easingStandard
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animationState
                    easing.type: Theme.easingStandard
                }
            }
        }

        Column {
            width: parent.width - 10
            spacing: -1

            Text {
                width: parent.width
                text: root.hasPlayer ? (root.player?.trackTitle || "UNTITLED") : "NO MEDIA SOURCE"
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                width: parent.width
                text: root.hasPlayer ? (root.player?.trackArtist || "UNKNOWN ARTIST").toUpperCase() : "PLAYER UNAVAILABLE"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.Medium
                font.letterSpacing: 0.5
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

    }

    PlayerPopup {
        id: popupWindow
        player: root.player
        implicitWidth: 400
        implicitHeight: 152
        artworkSize: 120
        popupSpacing: 16

        onEscapeDismissed: root.popupEscapeDismissed()
    }
}

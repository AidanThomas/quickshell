import qs.config
import qs.widgets.player
import QtQuick
import Quickshell.Services.Mpris

Item {
    id: root

    visible: root.hasPlayer

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    readonly property var player: Mpris.players.values.find(player => player.identity === "Spotify")
    readonly property bool hasPlayer: root.player !== undefined

    Text {
        font.family: Theme.fontFamily
        id: content

        text: `${root.player?.trackArtist ?? "Unknown"} - ${root.player?.trackTitle ?? "Unknown"}`
        color: Theme.text

        opacity: root.player && root.player.isPlaying ? 1.0 : 0.5

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                popupWindow.visible = !popupWindow.visible;
            } else if (mouse.button === Qt.RightButton) {
                root.player.togglePlaying();
            }
        }
    }

    PlayerPopup {
        id: popupWindow
        player: root.player
        width: 400
        height: 152
        artworkSize: 120
        popupSpacing: 16
    }
}

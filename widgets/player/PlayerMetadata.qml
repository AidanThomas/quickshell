import qs.config
import QtQuick
import Quickshell

Column {
    id: root

    required property var player

    spacing: 4

    Text {
        width: parent.width
        text: root.player?.trackTitle ?? ""
        color: Theme.text
        font.bold: true
        elide: Text.ElideRight
    }

    Text {
        width: parent.width
        text: root.player?.trackArtist ?? ""
        color: Theme.text
        opacity: 0.8
        elide: Text.ElideRight
    }

    Text {
        width: parent.width
        text: root.player?.trackAlbum ?? ""
        color: Theme.text
        opacity: 0.5
        elide: Text.ElideRight
    }
}

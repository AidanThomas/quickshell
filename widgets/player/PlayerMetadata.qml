import qs.config
import QtQuick

Column {
    id: root

    required property var player

    spacing: 4

    Text {
        font.family: Theme.fontFamily
        width: parent.width
        text: root.player?.trackTitle ?? ""
        color: Theme.textPrimary
        font.pixelSize: 13
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }

    Text {
        font.family: Theme.fontFamily
        width: parent.width
        text: root.player?.trackArtist ?? ""
        color: Theme.textMuted
        font.pixelSize: 10
        elide: Text.ElideRight
    }

    Text {
        font.family: Theme.fontFamily
        width: parent.width
        text: root.player?.trackAlbum ?? ""
        color: Theme.accentBlue
        font.pixelSize: 9
        elide: Text.ElideRight
    }
}

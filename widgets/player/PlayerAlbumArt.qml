import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property var player
    required property int artworkSize

    width: root.artworkSize
    height: root.artworkSize

    Image {
        id: albumArt
        anchors.fill: parent
        source: root.player?.trackArtUrl ?? ""
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    Rectangle {
        id: albumArtMask
        anchors.fill: parent
        radius: 20
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: parent
        source: albumArt
        maskEnabled: true
        maskSource: albumArtMask
    }
}

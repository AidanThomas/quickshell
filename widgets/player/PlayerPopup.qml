import qs.config
import qs.components

import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property var player
    required property int artworkSize
    required property int popupSpacing

    grabFocus: true

    anchor {
        item: parent

        edges: Edges.Bottom
        gravity: Edges.Bottom

        margins.top: 4
    }

    color: "transparent"

    PopupSurface {
        anchors.fill: parent
        padding: 16

        Row {
            id: popupContent

            anchors.fill: parent
            spacing: root.popupSpacing

            PlayerAlbumArt {
                id: albumArt
                player: root.player
                artworkSize: root.artworkSize
            }

            Column {
                id: playerDetails
                width: popupContent.width - albumArt.width - volumeControl.width - popupContent.spacing * 2

                anchors.top: parent.top
                spacing: 8

                PlayerMetadata {
                    id: metadata
                    player: root.player
                    width: parent.width
                }

                Item {
                    width: 1
                    height: 4
                }

                PlayerProgressControl {
                    id: progressControl
                    player: root.player
                    width: parent.width
                }

                PlayerTransportControls {
                    id: transportControls
                    player: root.player
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            PlayerVolumeControl {
                id: volumeControl
                player: root.player
                height: parent.height
            }
        }
    }
}

import qs.config
import qs.components

import QtQuick

DisclosurePopup {
    id: root

    required property var player
    required property int artworkSize
    required property int popupSpacing

    originEdge: DisclosureGeometry.Bottom
    surfaceGap: 4

    DisclosureSurface {
        anchors.fill: parent
        geometry: root.geometry
        revealProgress: root.revealProgress
        originEdge: root.originEdge
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

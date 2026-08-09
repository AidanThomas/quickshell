import qs.config
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
    id: root

    required property var node

    Layout.fillWidth: true
    implicitHeight: 30

    PwObjectTracker {
        objects: [root.node]
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Text {
            Layout.preferredWidth: 110
            text: root.node.description.length > 0 ? root.node.description : root.node.name
            color: Theme.text
            elide: Text.ElideRight
        }

        AudioMuteButton {
            muted: root.node.audio.muted
            onToggled: {
                root.node.audio.muted = !root.node.audio.muted
            }
        }

        AudioSlider {
            value: root.node.audio.volume
            onMoved: {
                root.node.audio.volume = value
            }
        }

        Text {
            text: Math.round(root.node.audio.volume * 100) + "%"
            color: Theme.textMuted
        }
    }
}

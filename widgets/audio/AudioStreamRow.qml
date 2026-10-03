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
            font.family: Theme.fontFamily
            Layout.preferredWidth: 110
            text: (root.node?.description?.length ?? 0) > 0 ? root.node.description : (root.node?.name ?? "Unknown stream")
            color: Theme.textPrimary
            elide: Text.ElideRight
        }

        AudioMuteButton {
            muted: root.node?.audio?.muted ?? true
            onToggled: {
                if (root.node?.audio)
                    root.node.audio.muted = !root.node.audio.muted;
            }
        }

        AudioSlider {
            value: root.node?.audio?.volume ?? 0
            onMoved: {
                if (root.node?.audio)
                    root.node.audio.volume = value;
            }
        }

        Text {
            font.family: Theme.fontFamily
            text: root.node?.audio ? Math.round(root.node.audio.volume * 100) + "%" : "--%"
            color: Theme.textMuted
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
    id: root

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    AudioPopup {
        id: popup
        anchorItem: root
        sink: root.sink
        source: root.source
        visible: false
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            popup.visible = !popup.visible
        }
    }

    RowLayout {
        id: content
        spacing: 6

        Text {
            text: {
                if (!root.sink)
                    return ""
                if (root.sink.audio.muted)
                    return "󰖁"
                return ""
            }
            color: "white"
        }

        Text {
            text: root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--%"
            color: "white"
        }
    }
}

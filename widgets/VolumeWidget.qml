import qs.config
import qs.widgets.audio
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

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                popup.visible = !popup.visible
            } else if (mouse.button === Qt.RightButton) {
                if (root.sink)
                    root.sink.audio.muted = !root.sink.audio.muted
            }
        }

        onWheel: wheel => {
            if (!root.sink)
                return

            const step = 0.02
            if (wheel.angleDelta.y > 0)  {
                root.sink.audio.volume = Math.min(1, root.sink.audio.volume + step)
            } else if (wheel.angleDelta.y < 0) {
                root.sink.audio.volume = Math.max(0, root.sink.audio.volume - step)
            }
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
            color: Theme.text
        }

        Text {
            text: root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--%"
            color: Theme.text
        }
    }
}

import qs.config
import qs.widgets.audio
import QtQuick
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
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.visible = !popup.visible
    }

    Row {
        id: content

        spacing: 10

        Item {
            implicitWidth: microphoneIcon.implicitWidth
            implicitHeight: microphoneIcon.implicitHeight

            Text {
                font.family: Theme.fontFamily
                id: microphoneIcon
                text: {
                    if (!root.source)
                        return "";

                    if (root.source.audio.muted)
                        return "";

                    return "";
                }

                color: Theme.text
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.source)
                        root.source.audio.muted = !root.source.audio.muted;
                }
            }
        }

        Item {
            implicitWidth: speakerContent.implicitWidth
            implicitHeight: speakerContent.implicitHeight

            Row {
                id: speakerContent
                spacing: 6

                Text {
                    font.family: Theme.fontFamily
                    id: speakerIcon
                    text: {
                        if (!root.sink)
                            return "";
                        if (root.sink.audio.muted)
                            return "󰖁";
                        return "";
                    }
                    color: Theme.text
                }

                Text {
                    font.family: Theme.fontFamily
                    id: speakerVolume
                    text: root.sink ? Math.round(root.sink.audio.volume * 100) + "%" : "--%"
                    color: Theme.text
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.sink)
                        root.sink.audio.muted = !root.sink.audio.muted;
                }

                onWheel: wheel => {
                    if (!root.sink)
                        return;
                    const step = 0.02;
                    if (wheel.angleDelta.y > 0) {
                        root.sink.audio.volume = Math.min(1, root.sink.audio.volume + step);
                    } else if (wheel.angleDelta.y < 0) {
                        root.sink.audio.volume = Math.max(0, root.sink.audio.volume - step);
                    }
                }
            }
        }
    }
}

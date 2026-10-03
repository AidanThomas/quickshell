import qs.config
import qs.widgets.audio
import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    implicitWidth: content.implicitWidth
    implicitHeight: Math.max(24, content.implicitHeight)

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool popupOpen: popup.visible
    readonly property bool inputMuted: root.source?.audio.muted ?? false
    readonly property bool outputMuted: root.sink?.audio.muted ?? false

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
        anchors.centerIn: parent
        spacing: 10

        Item {
            implicitWidth: Math.max(24, microphoneIcon.implicitWidth)
            implicitHeight: 24

            Text {
                font.family: Theme.iconFontFamily
                id: microphoneIcon
                anchors.centerIn: parent
                text: {
                    if (!root.source)
                        return "";

                    if (root.source.audio?.muted)
                        return "";

                    return "";
                }

                color: root.inputMuted ? Theme.accentAmber : Theme.textMuted

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animationState
                        easing.type: Theme.easingStandard
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.source?.audio)
                        root.source.audio.muted = !root.source.audio.muted;
                }
            }
        }

        Item {
            implicitWidth: Math.max(24, speakerContent.implicitWidth)
            implicitHeight: 24

            Row {
                id: speakerContent
                anchors.centerIn: parent
                spacing: 6

                Text {
                    font.family: Theme.iconFontFamily
                    id: speakerIcon
                    text: {
                        if (!root.sink)
                            return "";
                        if (root.sink.audio?.muted)
                            return "󰖁";
                        return "";
                    }
                    color: root.outputMuted ? Theme.accentAmber : Theme.accentCyan

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animationState
                            easing.type: Theme.easingStandard
                        }
                    }
                }

                Text {
                    font.family: Theme.fontFamily
                    id: speakerVolume
                    text: root.sink?.audio ? Math.round(root.sink.audio.volume * 100) + "%" : "--%"
                    color: root.outputMuted ? Theme.accentAmber : Theme.textPrimary

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animationState
                            easing.type: Theme.easingStandard
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.sink?.audio)
                        root.sink.audio.muted = !root.sink.audio.muted;
                }

                onWheel: wheel => {
                    if (!root.sink?.audio)
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

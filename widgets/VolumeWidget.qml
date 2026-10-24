pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.widgets.audio
import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    signal popupEscapeDismissed

    implicitWidth: content.implicitWidth
    implicitHeight: Math.max(24, content.implicitHeight)

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool popupOpen: popup.visible
    readonly property bool inputMuted: root.source?.audio.muted ?? false
    readonly property bool outputMuted: root.sink?.audio.muted ?? false
    readonly property bool inputAvailable: root.source?.audio !== undefined && root.source?.audio !== null
    readonly property bool outputAvailable: root.sink?.audio !== undefined && root.sink?.audio !== null
    readonly property bool childActionHovered: microphoneAction.hovered || outputAction.hovered
    readonly property string statusDescription: {
        const input = root.inputAvailable ? (root.inputMuted ? "microphone muted" : "microphone available") : "microphone unavailable";
        const output = root.outputAvailable
            ? (root.outputMuted ? "output muted" : `output ${Math.round(root.sink.audio.volume * 100)} percent`)
            : "output unavailable";
        return `${input}, ${output}`;
    }

    function togglePopup() {
        popup.visible = !popup.visible;
    }

    function closePopup() {
        popup.visible = false;
    }

    function toggleInputMute() {
        if (root.inputAvailable)
            root.source.audio.muted = !root.source.audio.muted;
    }

    function toggleOutputMute() {
        if (root.outputAvailable)
            root.sink.audio.muted = !root.sink.audio.muted;
    }

    function adjustOutputVolume(steps) {
        if (!root.outputAvailable || steps === 0)
            return;

        root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + steps * 0.02));
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    AudioPopup {
        id: popup
        anchorItem: root
        sink: root.sink
        source: root.source
        visible: false

        onEscapeDismissed: root.popupEscapeDismissed()
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 10

        IslandAction {
            id: microphoneAction

            text: root.inputMuted ? "Unmute microphone" : "Mute microphone"
            tooltipText: root.inputAvailable ? text : "Microphone unavailable"
            unavailable: !root.inputAvailable
            iconText: root.inputMuted ? "" : ""
            iconColor: root.inputMuted ? Theme.accentAmber : Theme.textMuted

            onClicked: root.toggleInputMute()
        }

        IslandAction {
            id: outputAction

            text: root.outputMuted ? "Unmute output" : "Mute output"
            tooltipText: root.outputAvailable ? text : "Audio output unavailable"
            unavailable: !root.outputAvailable
            iconColor: root.outputMuted ? Theme.accentAmber : Theme.accentCyan

            onClicked: root.toggleOutputMute()

            contentItem: Row {
                id: speakerContent
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
        }
    }
}

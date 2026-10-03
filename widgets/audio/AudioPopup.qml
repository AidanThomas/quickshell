import qs.config
import qs.components

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

PopupWindow {
    id: popup

    required property Item anchorItem
    required property var sink
    required property var source

    anchor {
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: 27
    }

    implicitWidth: 320
    implicitHeight: content.implicitHeight + 24

    color: "transparent"
    grabFocus: true

    PwObjectTracker {
        objects: [popup.sink, popup.source]
    }

    PopupSurface {
        anchors.fill: parent
        padding: 14

        ColumnLayout {
            id: content

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // Output header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        font.family: Theme.fontFamily
                        text: "OUTPUT"
                        color: Theme.accentCyan

                        font {
                            pixelSize: 11
                            bold: true
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        font.family: Theme.fontFamily
                        text: popup.sink?.audio ? Math.round(popup.sink.audio.volume * 100) + "%" : "--%"
                        color: popup.sink?.audio.muted ? Theme.accentAmber : Theme.textMuted
                        font.pixelSize: 11
                    }
                }

                // Output controls
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    AudioMuteButton {
                        muted: popup.sink?.audio?.muted ?? true
                        onToggled: {
                            if (popup.sink?.audio)
                                popup.sink.audio.muted = !popup.sink.audio.muted;
                        }
                    }

                    AudioSlider {
                        value: popup.sink?.audio?.volume ?? 0
                        onMoved: {
                            if (popup.sink?.audio)
                                popup.sink.audio.volume = value;
                        }
                    }
                }

                // Output devices
                AudioDeviceSelect {
                    id: outputDeviceSelect

                    selectedNode: popup.sink
                    deviceModel: Pipewire.nodes.values.filter(node => node.audio !== null && node.isSink && !node.isStream).map(node => ({
                                text: node.description.length > 0 ? node.description : node.name,
                                value: node
                            }))

                    onDeviceSelected: node => {
                        Pipewire.preferredDefaultAudioSink = node;
                    }

                    Connections {
                        target: Pipewire

                        function onReadyChanged() {
                            outputDeviceSelect.syncCurrentDevice();
                        }

                        function onDefaultAudioSinkChanged() {
                            outputDeviceSelect.syncCurrentDevice();
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // Input header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        font.family: Theme.fontFamily
                        text: "INPUT"
                        color: Theme.accentBlue

                        font {
                            pixelSize: 11
                            bold: true
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        font.family: Theme.fontFamily
                        text: popup.source?.audio ? Math.round(popup.source.audio.volume * 100) + "%" : "--%"
                        color: popup.source?.audio.muted ? Theme.accentAmber : Theme.textMuted
                        font.pixelSize: 11
                    }
                }

                // Input controls
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    AudioMuteButton {
                        muted: popup.source?.audio?.muted ?? true
                        activeIcon: ""
                        mutedIcon: ""
                        onToggled: {
                            if (popup.source?.audio)
                                popup.source.audio.muted = !popup.source.audio.muted;
                        }
                    }

                    AudioSlider {
                        value: popup.source?.audio?.volume ?? 0
                        onMoved: {
                            if (popup.source?.audio)
                                popup.source.audio.volume = value;
                        }
                    }
                }

                // Input devices
                AudioDeviceSelect {
                    id: inputDeviceSelect

                    selectedNode: popup.source
                    deviceModel: Pipewire.nodes.values.filter(node => node.audio !== null && !node.isSink && !node.isStream).map(node => ({
                                text: node.description.length > 0 ? node.description : node.name,
                                value: node
                            }))

                    onDeviceSelected: node => {
                        Pipewire.preferredDefaultAudioSource = node;
                    }

                    Connections {
                        target: Pipewire

                        function onReadyChanged() {
                            inputDeviceSelect.syncCurrentDevice();
                        }

                        function onDefaultAudioSourceChanged() {
                            inputDeviceSelect.syncCurrentDevice();
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.borderSubtle
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    font.family: Theme.fontFamily
                    text: "APPLICATIONS"
                    color: Theme.textMuted

                    font {
                        pixelSize: 11
                        bold: true
                    }
                }

                Repeater {
                    model: Pipewire.nodes

                    delegate: AudioStreamRow {
                        required property var modelData
                        node: modelData
                        visible: modelData.Audio !== null && modelData.isStream && modelData.isSink
                        implicitHeight: visible ? 30 : 0
                    }
                }
            }
        }
    }
}

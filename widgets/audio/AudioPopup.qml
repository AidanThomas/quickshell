import qs.config
import QtQuick
import QtQuick.Controls
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

    Rectangle {
        anchors.fill: parent

        topLeftRadius: 4
        topRightRadius: 4
        bottomLeftRadius: 12
        bottomRightRadius: 12
        color: Theme.surface

        ColumnLayout {
            id: content

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                leftMargin: 14
                rightMargin: 14
                topMargin: 12
            }

            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // Output header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "OUTPUT"
                        color: Theme.textMuted

                        font {
                            pixelSize: 11
                            bold: true
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: popup.sink ? Math.round(popup.sink.audio.volume * 100) + "%" : "--%"
                        color: Theme.textMuted
                        font.pixelSize: 11
                    }
                }

                // Output controls
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    AudioMuteButton {
                        muted: popup.sink ? popup.sink.audio.muted : true
                        onToggled: {
                            if (popup.sink)
                                popup.sink.audio.muted = !popup.sink.audio.muted
                        }
                    }

                    AudioSlider {
                        value: popup.sink ? popup.sink.audio.volume : 0
                        onMoved: {
                            if (popup.sink)
                                popup.sink.audio.volume = value
                        }
                    }
                }

                // Output devices
                AudioDeviceSelect {
                    id: outputDeviceSelect

                    selectedNode: popup.sink
                    deviceModel: Pipewire.nodes.values.filter(node =>
                        node.audio !== null && node.isSink && !node.isStream
                    ).map(node => ({
                        text: node.description.length > 0 ? node.description : node.name,
                        value: node
                    }))

                    onDeviceSelected: node => {
                        Pipewire.preferredDefaultAudioSink = node
                    }

                    Connections {
                        target: Pipewire

                        function onReadyChanged() {
                            outputDeviceSelect.syncCurrentDevice()
                        }

                        function onDefaultAudioSinkChanged() {
                            outputDeviceSelect.syncCurrentDevice()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight:  1
                color: Theme.border
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // Input header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "INPUT"
                        color: Theme.textMuted

                        font {
                            pixelSize: 11
                            bold: true
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: popup.source ? Math.round(popup.source.audio.volume * 100) + "%" : "--%"
                        color: Theme.textMuted
                        font.pixelSize: 11
                    }
                }

                // Input controls
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    AudioMuteButton {
                        muted: popup.source ? popup.source.audio.muted : true
                        activeIcon: ""
                        mutedIcon: ""
                        onToggled: {
                            if (popup.source)
                                popup.source.audio.muted = !popup.source.audio.muted
                        }
                    }

                    AudioSlider {
                        value: popup.source ? popup.source.audio.volume : 0
                        onMoved: {
                            if (popup.source)
                                popup.source.audio.volume = value
                        }
                    }

                }

                // Input devices
                AudioDeviceSelect {
                    id: inputDeviceSelect

                    selectedNode: popup.source
                    deviceModel: Pipewire.nodes.values.filter(node =>
                        node.audio !== null && !node.isSink && !node.isStream
                    ).map(node => ({
                        text: node.description.length > 0 ? node.description : node.name,
                        value: node
                    }))

                    onDeviceSelected: node => {
                        Pipewire.preferredDefaultAudioSource = node
                    }

                    Connections {
                        target: Pipewire

                        function onReadyChanged() {
                            inputDeviceSelect.syncCurrentDevice()
                        }

                        function onDefaultAudioSourceChanged() {
                            inputDeviceSelect.syncCurrentDevice()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.border
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "APPLICATIONS"
                    color: Theme.textMuted

                    font {
                        pixelSize: 11
                        bold: true
                    }
                }

                Repeater {
                    model: Pipewire.nodes

                    delegate: Item {
                        id: streamItem

                        required property var modelData

                        visible: modelData.audio !== null && modelData.isStream && modelData.isSink

                        Layout.fillWidth: true
                        implicitHeight: visible ? 30 : 0

                        PwObjectTracker {
                            objects: [streamItem.modelData]
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 8

                            Text {
                                Layout.preferredWidth: 110
                                text: streamItem.modelData.description.length > 0
                                    ? streamItem.modelData.description
                                    : streamItem.modelData.name

                                color: Theme.text
                                elide: Text.ElideRight
                            }

                            AudioMuteButton {
                                muted: streamItem.modelData.audio.muted
                                onToggled: {
                                    streamItem.modelData.audio.muted = !streamItem.modelData.audio.muted
                                }
                            }

                            AudioSlider {
                                value: streamItem.modelData.audio.volume
                                onMoved: {
                                    streamItem.modelData.audio.volume = value
                                }
                            }

                            Text {
                                text: Math.round(streamItem.modelData.audio.volume * 100) + "%"
                                color: Theme.textMuted
                            }
                        }
                    }
                }
            }
        }
    }
}

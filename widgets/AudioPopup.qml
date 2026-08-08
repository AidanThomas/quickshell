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
        color: "#202020"

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
                        color: "white"
                        opacity: 0.65

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
                        color: "white"
                        opacity: 0.65
                        font.pixelSize: 11
                    }
                }

                // Output controls
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: 6

                        color: outputMuteArea.containsMouse ? "#303030" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: {
                                if (!popup.sink || popup.sink.audio.muted)
                                    return "󰖁"

                                return ""
                            }

                            color: "white"
                        }

                        MouseArea {
                            id: outputMuteArea

                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (popup.sink)
                                    popup.sink.audio.muted = !popup.sink.audio.muted
                            }
                        }
                    }

                    Slider {
                        id: outputSlider

                        Layout.fillWidth: true

                        from: 0
                        to: 1

                        value: popup.sink ? popup.sink.audio.volume : 0

                        onMoved: {
                            if (popup.sink)
                                popup.sink.audio.volume = value
                        }

                        background: Rectangle {
                            x: outputSlider.leftPadding
                            y: outputSlider.topPadding + outputSlider.availableHeight / 2 - height / 2

                            width: outputSlider.availableWidth
                            height: 4
                            radius: 2

                            color: "#404040"

                            Rectangle {
                                width: outputSlider.visualPosition * parent.width
                                height: parent.height
                                radius: parent.radius
                                color: "white"
                            }
                        }

                        handle: Rectangle {
                            x: outputSlider.leftPadding
                                + outputSlider.visualPosition
                                * (outputSlider.availableWidth - width)
                            y: outputSlider.topPadding
                                + outputSlider.availableHeight / 2
                                - height / 2

                            implicitWidth: 12
                            implicitHeight: 12
                            radius: 6

                            color: "white"
                        }
                    }
                }

                // Output devices
                ComboBox {
                    id: outputDeviceSelect

                    Layout.fillWidth: true
                    implicitHeight: 30
                    model: Pipewire.nodes.values.filter(node =>
                        node.audio !== null && node.isSink && !node.isStream
                        ).map(node => ({
                            text: node.description.length > 0 ? node.description : node.namea,
                            value: node
                        }))

                    textRole: "text"
                    valueRole: "value"

                    function syncCurrentDevice() {
                        if (!Pipewire.ready || !popup.sink)
                            return

                        currentIndex = indexOfValue(popup.sink)
                    }

                    Component.onCompleted: syncCurrentDevice()

                    Connections {
                        target: Pipewire

                        function onReadyChanged() {
                            outputDeviceSelect.syncCurrentDevice()
                        }

                        function onDefaultAudioSinkChanged() {
                            outputDeviceSelect.syncCurrentDevice()
                        }
                    }

                    onActivated: {
                        Pipewire.preferredDefaultAudioSink = currentValue
                    }

                    contentItem: Text {
                        leftPadding: 10
                        rightPadding: 28

                        text: outputDeviceSelect.displayText
                        color: "white"

                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    indicator: Text {
                        text: "▾"
                        color: "white"
                        opacity: 0.65

                        anchors {
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    background: Rectangle {
                        radius: 6

                        color: outputDeviceSelect.hovered ? "#303030" : "#282828"

                        border.width: 1
                        border.color: "#404040"
                    }

                    delegate: ItemDelegate {
                        id: deviceDelegate

                        required property var model

                        width: outputDeviceSelect.width
                        implicitHeight: 30

                        contentItem: RowLayout {
                            spacing: 8

                            Rectangle {
                                implicitWidth: 8
                                implicitHeight: 8
                                radius: 4

                                color: model.value === outputDeviceSelect.currentValue ? "white" : "transparent"
                            }

                            Text {
                                Layout.fillWidth: true

                                text: model.text
                                color: "white"

                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                        }

                        background: Rectangle {
                            radius: 5
                            color: parent.hovered ? "#303030" : "transparent"
                        }
                    }

                    popup: Popup {
                        y: outputDeviceSelect.height + 4
                        width: outputDeviceSelect.width
                        implicitHeight: contentItem.implicitHeight + 8
                        padding: 4
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: outputDeviceSelect.popup.visible ? outputDeviceSelect.delegateModel : null
                            currentIndex: outputDeviceSelect.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator {}
                        }

                        background: Rectangle {
                            radius: 6
                            color: "#202020"

                            border.width: 1
                            border.color: "#404040"
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight:  1
                color: "#404040"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // Input header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "INPUT"
                        color: "white"
                        opacity: 0.65

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
                        color: "white"
                        opacity: 0.65
                        font.pixelSize: 11
                    }
                }

                // Input controls
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: 6

                        color: inputMuteArea.containsMouse ? "#303030" : "transparent"

                        Text {
                            anchors.centerIn: parent

                            text: {
                                if (!popup.source || popup.source.audio.muted)
                                    return ""

                                return ""
                            }

                            color: "white"

                            MouseArea {
                                id: inputMuteArea

                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (popup.source)
                                        popup.source.audio.muted = !popup.source.audio.muted
                                }
                            }
                        }
                    }

                    Slider {
                        id: inputSlider

                        Layout.fillWidth: true

                        from: 0
                        to: 1

                        value: popup.source ? popup.source.audio.volume : 0

                        onMoved: {
                            if (popup.source)
                                popup.source.audio.volume = value
                        }

                        background: Rectangle {
                            x: inputSlider.leftPadding
                            y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2

                            width: inputSlider.availableWidth
                            height: 4
                            radius: 2

                            color: "#404040"

                            Rectangle {
                                width: inputSlider.visualPosition * parent.width
                                height: parent.height
                                radius: parent.radius
                                color: "white"
                            }
                        }

                        handle: Rectangle {
                            x: inputSlider.leftPadding
                                + inputSlider.visualPosition
                                * (inputSlider.availableWidth - width)
                            y: inputSlider.topPadding
                                + inputSlider.availableHeight / 2
                                - height / 2

                            implicitWidth: 12
                            implicitHeight: 12
                            radius: 6

                            color: "white"
                        }

                    }
                }

                // Input devices
                ComboBox {
                    id: inputDeviceSelect

                    Layout.fillWidth: true
                    implicitHeight: 30
                    model: Pipewire.nodes.values.filter(node =>
                        node.audio !== null && !node.isSink && !node.isStream
                        ).map(node => ({
                            text: node.description.length > 0 ? node.description : node.namea,
                            value: node
                        }))

                    textRole: "text"
                    valueRole: "value"

                    function syncCurrentDevice() {
                        if (!Pipewire.ready || !popup.source)
                            return

                        currentIndex = indexOfValue(popup.source)
                    }

                    Component.onCompleted: syncCurrentDevice()

                    Connections {
                        target: Pipewire

                        function onReadyChanged() {
                            inputDeviceSelect.syncCurrentDevice()
                        }

                        function onDefaultAudioSinkChanged() {
                            inputDeviceSelect.syncCurrentDevice()
                        }
                    }

                    onActivated: {
                        Pipewire.preferredDefaultAudioSource = currentValue
                    }

                    contentItem: Text {
                        leftPadding: 10
                        rightPadding: 28

                        text: inputDeviceSelect.displayText
                        color: "white"

                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    indicator: Text {
                        text: "▾"
                        color: "white"
                        opacity: 0.65

                        anchors {
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    background: Rectangle {
                        radius: 6

                        color: inputDeviceSelect.hovered ? "#303030" : "#282828"

                        border.width: 1
                        border.color: "#404040"
                    }

                    delegate: ItemDelegate {
                        id: deviceDelegate

                        required property var model

                        width: inputDeviceSelect.width
                        implicitHeight: 30

                        contentItem: RowLayout {
                            spacing: 8

                            Rectangle {
                                implicitWidth: 8
                                implicitHeight: 8
                                radius: 4

                                color: model.value === inputDeviceSelect.currentValue ? "white" : "transparent"
                            }

                            Text {
                                Layout.fillWidth: true

                                text: model.text
                                color: "white"

                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                        }

                        background: Rectangle {
                            radius: 5
                            color: parent.hovered ? "#303030" : "transparent"
                        }
                    }

                    popup: Popup {
                        y: inputDeviceSelect.height + 4
                        width: inputDeviceSelect.width
                        implicitHeight: contentItem.implicitHeight + 8
                        padding: 4
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: inputDeviceSelect.popup.visible ? inputDeviceSelect.delegateModel : null
                            currentIndex: inputDeviceSelect.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator {}
                        }

                        background: Rectangle {
                            radius: 6
                            color: "#202020"

                            border.width: 1
                            border.color: "#404040"
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

ComboBox {
    id: root

    required property var selectedNode
    required property var deviceModel

    signal deviceSelected(var node)

    Layout.fillWidth: true
    implicitHeight: 30

    model: deviceModel

    textRole: "text"
    valueRole: "value"

    function syncCurrentDevice() {
        if (!Pipewire.ready || !root.selectedNode)
            return

        root.currentIndex = indexOfValue(root.selectedNode)
    }

    Component.onCompleted: syncCurrentDevice()

    // Connections {
    //     target: Pipewire
    //
    //     function onReadyChanged() {
    //         outputDeviceSelect.syncCurrentDevice()
    //     }
    //
    //     function onDefaultAudioSinkChanged() {
    //         outputDeviceSelect.syncCurrentDevice()
    //     }
    // }
    //
    // onActivated: {
    //     Pipewire.preferredDefaultAudioSink = currentValue
    // }

    contentItem: Text {
        leftPadding: 10
        rightPadding: 28

        text: root.displayText
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

        color: root.hovered ? "#303030" : "#282828"

        border.width: 1
        border.color: "#404040"
    }

    delegate: ItemDelegate {
        id: deviceDelegate

        required property var model

        width: root.width
        implicitHeight: 30

        contentItem: RowLayout {
            spacing: 8

            Rectangle {
                implicitWidth: 8
                implicitHeight: 8
                radius: 4

                color: model.value === root.currentValue ? "white" : "transparent"
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
            color: deviceDelegate.hovered ? "#303030" : "transparent"
        }
    }

    popup: Popup {
        y: root.height + 4
        width: root.width

        implicitHeight: contentItem.implicitHeight + 8
        padding: 4

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex

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

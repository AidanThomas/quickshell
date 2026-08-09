import qs.config
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

    contentItem: Text {
        leftPadding: 10
        rightPadding: 28

        text: root.displayText
        color: Theme.text

        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Text {
        text: "▾"
        color: Theme.textMuted

        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
    }

    background: Rectangle {
        radius: 6

        color: root.hovered ? Theme.surfaceHover : theme.surfaceRaised

        border.width: 1
        border.color: Theme.border
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

                color: model.value === root.currentValue ? Theme.text : "transparent"
            }

            Text {
                Layout.fillWidth: true

                text: model.text
                color: Theme.text

                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        background: Rectangle {
            radius: 5
            color: deviceDelegate.hovered ? Theme.surfaceHover : "transparent"
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
            color: Theme.surface

            border.width: 1
            border.color: Theme.border
        }
    }
}

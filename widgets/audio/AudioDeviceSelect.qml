pragma ComponentBehavior: Bound

import qs.config

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
            return;
        root.currentIndex = indexOfValue(root.selectedNode);
    }

    Component.onCompleted: syncCurrentDevice()

    contentItem: Text {
        font.family: Theme.fontFamily
        leftPadding: 10
        rightPadding: 28

        text: root.displayText
        color: Theme.textPrimary

        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Text {
        font.family: Theme.fontFamily
        text: "▾"
        color: Theme.textMuted

        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
    }

    background: Rectangle {
        radius: Theme.islandRadius

        color: root.hovered ? Theme.islandSurfaceHover : Theme.popupSurfaceRaised

        border.width: 1
        border.color: root.activeFocus ? Theme.accentCyan : (root.hovered ? Theme.borderHover : Theme.borderDefault)

        Behavior on color {
            ColorAnimation {
                duration: Theme.animationHover
                easing.type: Theme.easingStandard
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.animationHover
                easing.type: Theme.easingStandard
            }
        }
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

                color: deviceDelegate.model.value === root.currentValue ? Theme.accentCyan : "transparent"
            }

            Text {
                font.family: Theme.fontFamily
                Layout.fillWidth: true

                text: deviceDelegate.model.text
                color: Theme.textPrimary

                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        background: Rectangle {
            radius: 5
            color: deviceDelegate.hovered ? Theme.islandSurfaceHover : "transparent"
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
            radius: Theme.islandRadius
            color: Theme.popupSurfaceRaised

            border.width: 1
            border.color: Theme.borderDefault
        }
    }
}

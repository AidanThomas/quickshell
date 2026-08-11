import qs.config

import QtQuick
import Quickshell

Item {
    id: root

    required property int stackIndex

    property bool open: false
    property int toastSpacing: 10
    property var notification: null

    signal clicked()
    signal closed()

    visible: true
    width: parent?.width ?? 350
    height: toastContent.implicitHeight

    function showToast() {
        closeTimer.stop()
        root.open = true
        hideTimer.restart()
    }

    function hideToast() {
        if (!root.open)
            return

        hideTimer.stop()
        root.open = false
        closeTimer.restart()
    }

    Rectangle {
        id: toastContent
        width: parent.width
        implicitHeight: content.implicitHeight + 20
        x: root.open ? 0 : root.width
        y: root.stackIndex * (root.height + root.toastSpacing)
        color: Theme.surface

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.hideToast()
                root.clicked()
            }
        }


        Column {
            id: content

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 10
            }

            spacing: 4

            Text {
                text: root.notification?.appName ?? ""
                color: Theme.textMuted
            }

            Text {
                text: root.notification?.summary ?? ""
                color: Theme.text
            }

            Text {
                width: parent.width
                text: root.notification?.body ?? ""
                color: Theme.textMuted
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
            }
        }

        Item {
            id: dismissButton
            width: 24
            height: 24

            anchors {
                top: parent.top
                right: parent.right
                topMargin: 8
                rightMargin: 8
            }

            z: 10

            Text {
                anchors.centerIn: parent
                text: "󰅖"
                color: Theme.textMuted
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.notification?.dismiss()
                    root.hideToast()
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        repeat: false
        onTriggered: root.hideToast()
    }

    Timer {
        id: closeTimer
        interval: 200
        repeat: false
        onTriggered: root.closed()
    }
}

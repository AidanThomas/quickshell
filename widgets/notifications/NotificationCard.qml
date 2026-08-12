import qs.config

import QtQuick
import Quickshell

import "NotificationUtils.js" as NotificationUtils

Rectangle {
    id: root

    required property var notification

    property bool showTimestamp: false
    property string timestamp: ""

    signal clicked
    signal dismissRequested

    implicitHeight: content.implicitHeight + 20
    color: Theme.background

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Row {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }

        spacing: 10

        Image {
            id: appIcon
            width: 32
            height: 32
            sourceSize.width: 64
            sourceSize.height: 64
            source: {
                const icon = NotificationUtils.iconFor(root.notification, DesktopEntries.applications.values);
                return icon !== "" ? Quickshell.iconPath(icon, true) : "";
            }
            fillMode: Image.PreserveAspectFit
            visible: source.toString() !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            id: notificationContent
            width: parent.width - appIcon.width - dismissButton.width - parent.spacing * 2
            spacing: 2

            Row {
                width: parent.width

                Text {
                    id: appName
                    text: root.notification.appName
                    color: Theme.textMuted
                }

                Item {
                    width: parent.width - appName.implicitWidth - notificationTime.implicitWidth
                    height: 1
                }

                Text {
                    id: notificationTime
                    visible: root.showTimestamp
                    text: root.timestamp
                    color: Theme.textMuted
                }
            }

            Text {
                text: root.notification.summary
                color: Theme.text
            }

            Text {
                width: parent.width
                text: root.notification.body
                color: Theme.textMuted
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
            }
        }

        Item {
            id: dismissButton
            width: 24
            height: 24
            z: 1

            Text {
                anchors.centerIn: parent
                text: "󰅖"
                color: Theme.textMuted
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dismissRequested()
            }
        }
    }
}

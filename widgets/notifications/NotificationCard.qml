import qs.config

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

import "NotificationUtils.js" as NotificationUtils

Rectangle {
    id: root

    property var notification: null

    property bool showTimestamp: false
    property string timestamp: ""

    signal clicked
    signal dismissed

    implicitHeight: content.implicitHeight + 20
    radius: Theme.islandRadius
    color: cardMouse.containsMouse ? Theme.popupSurfaceRaised : Theme.islandSurfaceActive
    border.width: Theme.islandBorderWidth
    border.color: root.notification?.urgency === 2 ? Theme.accentRed : Theme.borderDefault

    Behavior on color {
        ColorAnimation {
            duration: Theme.animationHover
            easing.type: Theme.easingStandard
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: Theme.animationState
            easing.type: Theme.easingStandard
        }
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
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
                if (!root.notification)
                    return "";
                const icon = NotificationUtils.iconFor(root.notification, DesktopEntries.applications.values);
                return icon !== "" ? Quickshell.iconPath(icon, true) : "";
            }
            fillMode: Image.PreserveAspectFit
            visible: source.toString() !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        NotificationContent {
            showTimestamp: root.showTimestamp
            notification: root.notification
            timestamp: root.timestamp
            width: parent.width - appIcon.width - parent.spacing * 2
        }

        Item {
            id: dismissButton
            width: 24
            height: 24
            z: 1

            Text {
                font.family: Theme.iconFontFamily
                anchors.centerIn: parent
                text: "󰅖"
                color: dismissMouse.containsMouse ? Theme.accentRed : Theme.textMuted

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animationHover
                        easing.type: Theme.easingStandard
                    }
                }
            }

            MouseArea {
                id: dismissMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dismissed()
            }
        }
    }
}

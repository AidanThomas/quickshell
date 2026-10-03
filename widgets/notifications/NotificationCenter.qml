pragma ComponentBehavior: Bound

import qs.config
import qs.components

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import "NotificationUtils.js" as NotificationUtils

PanelWindow {
    id: root

    required property bool doNotDisturb
    required property var notificationServer
    required property var receivedAtFor
    required property var dismissNotification
    required property var clearNotifications

    property bool open: false

    signal doNotDisturbToggled

    visible: true

    anchors {
        top: true
        right: true
        bottom: true
    }

    implicitWidth: 400
    implicitHeight: screen.height - 50

    margins {
        top: 45
        right: 5
        bottom: 10
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    mask: Region {
        item: notificationCenter
    }

    function openApplication(notification) {
        const entry = NotificationUtils.desktopEntryFor(notification, DesktopEntries.applications.values);

        if (!entry)
            return;
        const expectedIds = [entry.id.toLowerCase(), entry.startupClass.toLowerCase()];

        for (const toplevel of ToplevelManager.toplevels.values) {
            const appId = toplevel.appId.toLowerCase();
            if (expectedIds.includes(appId)) {
                toplevel.activate();
                root.open = false;
                return;
            }
        }

        entry.execute();
        root.open = false;
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        active: root.open
        onCleared: {
            root.open = false;
        }
    }

    PopupSurface {
        id: notificationCenter
        width: parent.width
        height: parent.height
        x: root.open ? 0 : root.width
        padding: 16
        accentColor: root.doNotDisturb ? Theme.accentBlue : Theme.accentCyan

        Behavior on x {
            NumberAnimation {
                duration: Theme.animationState
                easing.type: Theme.easingEntrance
            }
        }

        Column {
            anchors {
                fill: parent
            }

            spacing: 12

            Row {
                width: parent.width

                Text {
                    font.family: Theme.fontFamily
                    id: notificationsTitle
                    text: "NOTIFICATIONS"
                    color: Theme.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                }

                Item {
                    width: parent.width - notificationsTitle.width - clearAll.implicitWidth - doNotDisturbToggle.implicitWidth
                    height: 1
                }

                Text {
                    font.family: Theme.fontFamily
                    id: clearAll
                    text: "CLEAR"
                    color: clearAllMouse.containsMouse ? Theme.accentAmber : Theme.textMuted
                    font.pixelSize: 10
                    visible: root.notificationServer.trackedNotifications.values.length > 0

                    MouseArea {
                        id: clearAllMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.clearNotifications()
                    }
                }

                Text {
                    font.family: Theme.fontFamily
                    id: doNotDisturbToggle
                    text: root.doNotDisturb ? "DND ON" : "DND OFF"
                    color: root.doNotDisturb ? Theme.accentBlue : Theme.textMuted
                    font.pixelSize: 10

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.doNotDisturbToggled()
                    }
                }
            }

            ListView {
                width: parent.width
                height: parent.height - y
                spacing: 8
                clip: true
                model: root.notificationServer.trackedNotifications

                delegate: NotificationCard {
                    required property var modelData

                    width: ListView.view.width
                    notification: modelData
                    showTimestamp: true
                    timestamp: {
                        const time = root.receivedAtFor(modelData);
                        return time ? Qt.formatTime(time, "HH:mm") : "";
                    }
                    onClicked: root.openApplication(modelData)
                    onDismissed: root.dismissNotification(modelData)
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound

import qs.config

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

    Rectangle {
        id: notificationCenter
        width: parent.width
        height: parent.height
        x: root.open ? 0 : root.width
        color: Theme.surface

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Column {
            anchors {
                fill: parent
                margins: 16
            }

            spacing: 12

            Row {
                width: parent.width

                Text {
                    id: notificationsTitle
                    text: "Notifications"
                    color: Theme.text
                }

                Item {
                    width: parent.width - notificationsTitle.width - clearAll.implicitWidth - doNotDisturbToggle.implicitWidth
                    height: 1
                }

                Text {
                    id: clearAll
                    text: "Clear all"
                    color: Theme.textMuted
                    visible: root.notificationServer.trackedNotifications.values.length > 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.clearNotifications()
                    }
                }

                Text {
                    id: doNotDisturbToggle
                    text: root.doNotDisturb ? "DND: On" : "DND: Off"
                    color: Theme.textMuted

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
                spacing: 5
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
                    onDismissRequested: root.dismissNotification(modelData)
                }
            }
        }
    }
}

import qs.config

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var notificationServer
    required property var notificationTimes
    required property bool doNotDisturb

    property bool open: false

    signal doNotDisturbToggled()

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

    function receivedAtFor(notification) {
        for (const entry of notificationTimes) {
            if (entry.notification === notification)
                return entry.receivedAt
        }

        return null
    }

    function desktopEntryFor(notification) {
        if (notification.desktopEntry !== "") {
            for (const entry of DesktopEntries.applications.values) {
                if (entry.id === notification.desktopEntry)
                    return entry
            }
        }

        for (const entry of DesktopEntries.applications.values) {
            if (entry.name.toLowerCase() === notification.appName.toLowerCase())
                return entry
        }

        return null
    }

    function openApplication(notification) {
        const entry = root.desktopEntryFor(notification)

        if (!entry)
            return

            const expectedIds = [
                entry.id.toLowerCase(),
                entry.startupClass.toLowerCase()
            ]

        for (const toplevel of ToplevelManager.toplevels.values) {
            const appId = toplevel.appId.toLowerCase()
            if (expectedIds.includes(appId)) {
                toplevel.activate()
                root.open = false
                return
            }
        }

        entry.execute()
        root.open = false
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        active: root.open
        onCleared: {
            root.open = false
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
                    width: parent.width
                        - notificationsTitle.width
                        - clearAll.implicitWidth
                        - doNotDisturbToggle.implicitWidth
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
                        onClicked: {
                            const notifications = [...root.notificationServer.trackedNotifications.values]
                            for (const notification of notifications) {
                                notification.dismiss()
                            }
                        }
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

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: notificationContent.implicitHeight + 20
                    color: Theme.background

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openApplication(modelData)
                    }

                    Row {
                        anchors {
                            fill: parent
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
                                if (modelData.appIcon !== "")
                                    return Quickshell.iconPath(modelData.appIcon, true)

                                if (modelData.desktopEntry !== "")
                                    return Quickshell.iconPath(modelData.desktopEntry, true)

                                for (const entry of DesktopEntries.applications.values) {
                                    if (entry.name.toLowerCase() === modelData.appName.toLowerCase()) {
                                        return Quickshell.iconPath(entry.icon, true)
                                    }
                                }

                                return ""
                            }
                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            id: notificationContent
                            width: parent.width
                                - appIcon.width
                                - dismissButton.width
                                - parent.spacing * 2
                            spacing: 2

                            Row {
                                width: parent.width

                                Text {
                                    id: appName
                                    text: modelData.appName
                                    color: Theme.textMuted
                                }

                                Item {
                                    width: parent.width
                                        - appName.implicitWidth
                                        - notificationTime.implicitWidth
                                    height: 1
                                }

                                Text {
                                    id: notificationTime
                                    text: {
                                        const time = root.receivedAtFor(modelData)
                                        return time ? Qt.formatTime(time, "HH:mm") : ""
                                    }
                                    color: Theme.textMuted
                                }
                            }

                            Text {
                                text: modelData.summary
                                color: Theme.text
                            }

                            Text {
                                width: parent.width
                                text: modelData.body
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
                                onClicked: modelData.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

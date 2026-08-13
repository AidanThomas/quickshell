pragma ComponentBehavior: Bound

import qs.config
import qs.widgets.notifications

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    property bool doNotDisturb: false
    property int unreadCount: 0
    property var notificationTimeStamps: []

    function removeToast(notification) {
        for (let i = 0; i < toastModel.count; i++) {
            if (toastModel.get(i).notification === notification) {
                toastModel.remove(i);
                return;
            }
        }
    }

    function hideAllToasts() {
        for (let i = 0; i < toastRepeater.count; i++) {
            const toast = toastRepeater.itemAt(i);
            if (toast?.open)
                toast.hideToast();
        }
    }

    function recordNotificationTimeStamp(notification) {
        notificationTimeStamps = [...notificationTimeStamps,
            {
                notification: notification,
                receivedAt: new Date()
            }
        ];
    }

    function receivedAtFor(notification) {
        const entry = notificationTimeStamps.find(entry => entry.notification === notification);
        return entry?.receivedAt ?? null;
    }

    function removeNotificationTimestamp(notification) {
        notificationTimeStamps = notificationTimeStamps.filter(entry => entry.notification !== notification);
    }

    function dismissNotification(notification) {
        removeNotificationTimestamp(notification);
        notification.dismiss();
    }

    function clearNotifications() {
        for (const notification of notificationServer.trackedNotifications.values) {
            notification.dismiss();
        }
        notificationTimeStamps = [];
    }

    NotificationServer {
        id: notificationServer
        onNotification: notification => {
            notification.tracked = true;

            root.recordNotificationTimeStamp(notification);

            if (!notificationCenter.open) {
                root.unreadCount++;

                if (!root.doNotDisturb) {
                    toastModel.insert(0, {
                        notification: notification
                    });
                }
            }
        }
    }

    ListModel {
        id: toastModel
        dynamicRoles: true
    }

    RowLayout {
        id: content
        spacing: 4

        Text {
            text: root.doNotDisturb ? "󰂛" : "󰂚"
            color: Theme.text
        }

        Text {
            visible: root.unreadCount > 0
            text: root.unreadCount
            color: Theme.text
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button == Qt.RightButton) {
                root.doNotDisturb = !root.doNotDisturb;

                if (root.doNotDisturb)
                    root.hideAllToasts();

                return;
            }

            notificationCenter.open = !notificationCenter.open;
            if (notificationCenter.open) {
                root.unreadCount = 0;
                root.hideAllToasts();
            }
        }
    }

    NotificationCenter {
        id: notificationCenter
        notificationServer: notificationServer
        receivedAtFor: root.receivedAtFor
        dismissNotification: root.dismissNotification
        doNotDisturb: root.doNotDisturb
        onDoNotDisturbToggled: {
            root.doNotDisturb = !root.doNotDisturb;
            if (root.doNotDisturb)
                root.hideAllToasts();
        }
    }

    PanelWindow {
        id: toastLayer
        visible: true

        anchors {
            top: true
            right: true
        }

        margins {
            top: 50
            right: 10
        }

        implicitWidth: 350
        implicitHeight: toastModel.count * 150
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        Repeater {
            id: toastRepeater
            model: toastModel

            delegate: NotificationToast {
                required property var model
                required property int index
                width: toastLayer.width
                notification: model.notification
                stackIndex: index
                Component.onCompleted: showToast()
                onClicked: {
                    notificationCenter.open = true;
                    root.unreadCount = 0;
                    root.hideAllToasts();
                }
                onClosed: root.removeToast(notification)
            }
        }
    }
}

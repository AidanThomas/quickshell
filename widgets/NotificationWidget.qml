pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.widgets.notifications

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    required property Item popupOrigin

    implicitWidth: content.implicitWidth
    implicitHeight: Math.max(24, content.implicitHeight)

    property bool doNotDisturb: false
    property int unreadCount: 0
    property var notificationTimeStamps: []
    readonly property alias disclosure: notificationCenter.lifecycle
    readonly property bool popupOpen: notificationCenter.effectiveOpen
    // NotificationUrgency.Critical is enum value 2 in the installed API, but
    // its singleton is not exposed to expressions by this Quickshell build.
    readonly property bool hasUrgent: notificationServer.trackedNotifications.values.some(notification => notification.urgency === 2)

    function requestPopupOpen(inputSource = DisclosureLifecycle.ProgrammaticInput): bool {
        return notificationCenter.requestOpen(inputSource);
    }

    function togglePopup(inputSource = DisclosureLifecycle.ProgrammaticInput): bool {
        return notificationCenter.toggle(inputSource);
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

            if (!notificationCenter.lifecycle.requestedOpen) {
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
        anchors.centerIn: parent
        spacing: 4

        Text {
            font.family: Theme.iconFontFamily
            text: root.doNotDisturb ? "󰂛" : "󰂚"
            color: root.hasUrgent
                ? Theme.accentRed
                : (root.unreadCount > 0 ? Theme.accentAmber : (root.doNotDisturb ? Theme.textMuted : Theme.textPrimary))

            Behavior on color {
                ColorAnimation {
                    duration: MotionPreferences.duration(Theme.motionStateDuration)
                    easing.type: Theme.motionStateEasing
                }
            }
        }

        Text {
            font.family: Theme.fontFamily
            visible: root.unreadCount > 0
            text: root.unreadCount > 99 ? "99+" : root.unreadCount
            color: root.hasUrgent ? Theme.accentRed : Theme.accentAmber
            font.pixelSize: root.unreadCount > 99 ? 9 : 11
            font.weight: Font.DemiBold
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

            const opening = !notificationCenter.lifecycle.requestedOpen;
            const changed = root.togglePopup(DisclosureLifecycle.Pointer);
            if (opening && changed) {
                root.unreadCount = 0;
                root.hideAllToasts();
            }
        }
    }

    NotificationCenter {
        id: notificationCenter
        origin: root.popupOrigin
        notificationServer: notificationServer
        receivedAtFor: root.receivedAtFor
        dismissNotification: root.dismissNotification
        clearNotifications: root.clearNotifications
        doNotDisturb: root.doNotDisturb
        onDoNotDisturbToggled: {
            root.doNotDisturb = !root.doNotDisturb;
            if (root.doNotDisturb)
                root.hideAllToasts();
        }
    }

    PanelWindow {
        id: toastLayer
        // Unmap the layer once the last toast is gone so an empty transparent
        // surface can never intercept clicks in the top-right of applications.
        visible: toastModel.count > 0

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
                    root.requestPopupOpen(DisclosureLifecycle.Pointer);
                    root.unreadCount = 0;
                    root.hideAllToasts();
                }
                // ListModel may wrap QObject values, making identity-based lookup
                // unreliable. The delegate's current index is the authoritative
                // entry to remove.
                onClosed: toastModel.remove(index)
            }
        }
    }
}

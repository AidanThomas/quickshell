import QtQuick

Item {
    id: root

    required property int stackIndex

    property bool open: false
    property int toastSpacing: 10
    property var notification: null

    signal clicked
    signal closed

    visible: true
    width: parent?.width ?? 350
    height: toastContent.implicitHeight

    function showToast() {
        closeTimer.stop();
        root.open = true;
        hideTimer.restart();
    }

    function hideToast() {
        if (!root.open)
            return;
        hideTimer.stop();
        root.open = false;
        closeTimer.restart();
    }

    NotificationCard {
        id: toastContent
        width: parent.width
        notification: root.notification
        showTimestamp: false
        x: root.open ? 0 : root.width
        y: root.stackIndex * (root.height + root.toastSpacing)
        onClicked: {
            root.hideToast();
            root.clicked();
        }
        onDismissRequested: {
            root.notification?.dismiss();
            root.hideToast();
        }

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

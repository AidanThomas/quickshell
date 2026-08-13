import qs.config

import QtQuick

Column {
    id: root

    required property bool showTimestamp
    required property var notification

    property string timestamp: ""

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

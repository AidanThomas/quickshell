import qs.config

import QtQuick

Column {
    id: root

    required property bool showTimestamp
    property var notification: null

    property string timestamp: ""

    spacing: 2

    Row {
        width: parent.width

        Text {
            font.family: Theme.fontFamily
            id: appName
            text: (root.notification?.urgency === 2 ? "CRITICAL · " : "")
                + (root.notification?.appName ?? "Unknown application")
            color: Theme.accentBlue
            font.pixelSize: 9
            font.weight: Font.DemiBold
            font.letterSpacing: 0.5
        }

        Item {
            width: parent.width - appName.implicitWidth - notificationTime.implicitWidth
            height: 1
        }

        Text {
            font.family: Theme.fontFamily
            id: notificationTime
            visible: root.showTimestamp
            text: root.timestamp
            color: Theme.textMuted
            font.pixelSize: 9
        }
    }

    Text {
        font.family: Theme.fontFamily
        text: root.notification?.summary ?? ""
        color: Theme.textPrimary
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }

    Text {
        font.family: Theme.fontFamily
        width: parent.width
        text: root.notification?.body ?? ""
        color: Theme.textMuted
        wrapMode: Text.Wrap
        textFormat: Text.PlainText
        maximumLineCount: 4
        elide: Text.ElideRight
    }
}

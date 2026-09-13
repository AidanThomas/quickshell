import qs.config
import QtQuick
import Quickshell

Rectangle {
    implicitHeight: clockContent.implicitHeight
    implicitWidth: clockContent.implicitWidth
    color: "transparent"

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Row {
        id: clockContent
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 20
            font.weight: Font.DemiBold
            font.letterSpacing: 0.5
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -1

            Text {
                text: Qt.formatDateTime(clock.date, "ddd").toUpperCase()
                color: Theme.workspaceActive
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 1
            }

            Text {
                text: Qt.formatDateTime(clock.date, "MMM dd").toUpperCase()
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.Medium
                font.letterSpacing: 0.5
            }
        }
    }
}

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
        spacing: 7

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 19
            font.weight: Font.DemiBold
            font.letterSpacing: 0.5
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -1

            Text {
                text: Qt.formatDateTime(clock.date, "ddd").toUpperCase()
                color: Theme.accentCyan
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

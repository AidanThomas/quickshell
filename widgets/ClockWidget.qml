import qs.config
import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    implicitHeight: clockText.implicitHeight
    implicitWidth: clockText.implicitWidth
    color: "transparent"

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "ddd dd MMM hh:mm")
        color: Theme.text
    }
}

import qs.config
import qs.components
import QtQuick
import Quickshell

Rectangle {
    id: root

    required property Item popupOrigin

    implicitHeight: clockContent.implicitHeight
    implicitWidth: clockContent.implicitWidth
    color: "transparent"

    readonly property var locale: Qt.locale()
    readonly property alias disclosure: calendarPopup.lifecycle

    function toggleCalendar(inputSource = DisclosureLifecycle.ProgrammaticInput) {
        calendarPopup.toggle(inputSource);
    }

    function closeCalendar(reason = DisclosureLifecycle.Programmatic, inputSource = DisclosureLifecycle.ProgrammaticInput) {
        calendarPopup.requestClose(reason, inputSource);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: clockContent
        anchors.centerIn: parent
        spacing: 7

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                anchors.baseline: minuteText.baseline
                text: root.locale.toString(clock.date, "HH")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 22
                font.weight: Font.Bold
                font.letterSpacing: 0
            }

            Text {
                id: minuteText

                text: root.locale.toString(clock.date, "mm")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 22
                font.weight: Font.Light
                font.letterSpacing: 0
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: root.locale.toString(clock.date, "d MMM")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.weight: Font.Normal
                font.letterSpacing: 0
            }

            Text {
                text: root.locale.toString(clock.date, "ddd")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.weight: Font.Normal
                font.letterSpacing: 0
            }
        }
    }

    CalendarPopup {
        id: calendarPopup

        origin: root.popupOrigin
        currentDate: clock.date
    }
}

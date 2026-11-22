import qs.config

import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property ShellScreen output

    screen: output
    implicitWidth: clockContent.implicitWidth + 28
    implicitHeight: Theme.topBarHeight
    color: "transparent"
    focusable: false
    exclusiveZone: 0

    anchors {
        top: true
        right: true
    }

    WlrLayershell.namespace: "quickshell:secondary-glance"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Secondary surfaces are deliberately glance-only and never intercept input.
    mask: Region {
        width: 0
        height: 0
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.glassBarSurface
        radius: Theme.barSegmentRadius

        border {
            width: Theme.islandBorderWidth
            color: Theme.borderDefault
        }
    }

    Row {
        id: clockContent

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: systemClock.date.toLocaleTimeString(Qt.locale(), "HH:mm")
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Text {
            text: systemClock.date.toLocaleDateString(Qt.locale(), "ddd d MMM")
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }
}

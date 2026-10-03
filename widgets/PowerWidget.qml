import qs.config
import qs.widgets.power

import QtQuick

Item {
    id: root

    implicitWidth: Math.max(24, icon.implicitWidth)
    implicitHeight: Math.max(24, icon.implicitHeight)
    readonly property bool menuOpen: powerMenu.visible

    Text {
        font.family: Theme.iconFontFamily
        id: icon
        anchors.centerIn: parent
        text: ""
        color: root.menuOpen ? Theme.accentRed : Theme.textPrimary
        font.pixelSize: 18

        Behavior on color {
            ColorAnimation {
                duration: Theme.animationState
                easing.type: Theme.easingStandard
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: powerMenu.toggle()
    }

    PowerMenu {
        id: powerMenu
    }
}

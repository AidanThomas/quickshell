import qs.config

import QtQuick
import QtQuick.Controls

AbstractButton {
    id: root

    property string iconText: ""
    property color iconColor: Theme.textPrimary
    property string tooltipText: ""
    property bool unavailable: false

    implicitWidth: Math.max(28, contentItem.implicitWidth + 8)
    implicitHeight: 28
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true
    opacity: unavailable ? 0.45 : 1

    Accessible.name: text
    Accessible.description: tooltipText

    background: Rectangle {
        radius: Theme.islandRadius
        color: (root.down && !root.unavailable) || root.visualFocus
            ? Theme.islandSurfaceActive
            : (root.hovered ? Theme.islandSurfaceHover : "transparent")
        border.width: root.visualFocus ? 1 : 0
        border.color: Theme.borderHover

        Behavior on color {
            ColorAnimation {
                duration: Theme.animationHover
                easing.type: Theme.easingStandard
            }
        }
    }

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.iconText
        color: root.iconColor
        font.family: Theme.iconFontFamily
    }

    ToolTip.visible: root.hovered && root.tooltipText.length > 0
    ToolTip.text: root.tooltipText
    ToolTip.delay: 650

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animationState
            easing.type: Theme.easingStandard
        }
    }
}

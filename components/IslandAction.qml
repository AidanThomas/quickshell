import qs.config

import QtQuick
import QtQuick.Controls

AbstractButton {
    id: root

    property string iconName: ""
    property color iconColor: Theme.textPrimary
    property real iconSize: 16
    property point iconOpticalOffset: Qt.point(0, 0)
    property string tooltipText: ""
    property bool unavailable: false

    implicitWidth: Math.max(28, contentItem.implicitWidth + 8)
    implicitHeight: 28
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true
    enabled: !unavailable
    opacity: unavailable ? Theme.iconUnavailableOpacity : 1

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
                duration: MotionPreferences.duration(Theme.motionFeedbackDuration)
                easing.type: Theme.motionFeedbackEasing
            }
        }
    }

    contentItem: ShellIcon {
        name: root.iconName
        color: root.iconColor
        iconSize: root.iconSize
        opticalOffset: root.iconOpticalOffset
        unavailable: false
    }

    ToolTip.visible: root.hovered && root.tooltipText.length > 0
    ToolTip.text: root.tooltipText
    ToolTip.delay: 650

    HoverHandler {
        cursorShape: root.unavailable ? Qt.ArrowCursor : Qt.PointingHandCursor
    }

    Behavior on opacity {
        NumberAnimation {
            duration: MotionPreferences.duration(Theme.motionStateDuration)
            easing.type: Theme.motionStateEasing
        }
    }

}

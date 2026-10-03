import qs.config

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Slider {
    id: root

    Layout.fillWidth: true

    from: 0
    to: 1

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 4
        radius: 2
        color: Theme.borderSubtle

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: Theme.accentCyan
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 12
        implicitHeight: 12
        radius: 6
        color: root.pressed || root.hovered ? Theme.textPrimary : Theme.accentCyan

        Behavior on color {
            ColorAnimation {
                duration: Theme.animationHover
                easing.type: Theme.easingStandard
            }
        }
    }
}

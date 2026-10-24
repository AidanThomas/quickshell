import qs.config

import QtQuick

Item {
    id: root

    property color fillColor: "transparent"
    property color outlineColor: "transparent"
    property color highlightColor: Theme.glassEdgeHighlight
    property real outlineWidth: 1
    property real cutSize: 5
    property real radius: Theme.islandRadius
    property bool highlightVisible: true

    Behavior on fillColor {
        ColorAnimation {
            duration: Theme.animationHover
            easing.type: Theme.easingStandard
        }
    }

    Behavior on outlineColor {
        ColorAnimation {
            duration: Theme.animationHover
            easing.type: Theme.easingStandard
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Math.min(root.radius, height / 2)
        color: root.fillColor
        border.width: root.outlineWidth
        border.color: root.outlineColor
        antialiasing: true
    }

    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 1
        width: Math.max(0, parent.width - root.radius * 1.5)
        height: 1
        radius: 0.5
        color: root.highlightColor
        visible: root.highlightVisible
        opacity: 0.45
    }
}

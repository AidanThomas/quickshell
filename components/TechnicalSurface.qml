import qs.config

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color fillColor: "transparent"
    property color outlineColor: "transparent"
    property color highlightColor: Theme.glassEdgeHighlight
    property real outlineWidth: 1
    property real cutSize: 5
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

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeColor: root.outlineColor
            strokeWidth: root.outlineWidth
            fillColor: root.fillColor
            joinStyle: ShapePath.MiterJoin

            startX: root.outlineWidth / 2
            startY: root.outlineWidth / 2
            PathLine { x: root.width - root.cutSize; y: root.outlineWidth / 2 }
            PathLine { x: root.width - root.outlineWidth / 2; y: root.cutSize }
            PathLine { x: root.width - root.outlineWidth / 2; y: root.height - root.outlineWidth / 2 }
            PathLine { x: root.cutSize; y: root.height - root.outlineWidth / 2 }
            PathLine { x: root.outlineWidth / 2; y: root.height - root.cutSize }
            PathLine { x: root.outlineWidth / 2; y: root.outlineWidth / 2 }
        }
    }

    Shape {
        anchors.fill: parent
        antialiasing: true
        visible: root.highlightVisible

        ShapePath {
            strokeColor: root.highlightColor
            strokeWidth: 1
            fillColor: "transparent"
            joinStyle: ShapePath.MiterJoin
            capStyle: ShapePath.FlatCap

            startX: 1
            startY: 1.5
            PathLine { x: root.width - root.cutSize; y: 1.5 }
            PathLine { x: root.width - 1; y: root.cutSize }
        }
    }
}

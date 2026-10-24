pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: frame

    required property color fillColor
    required property int cornerRadius
    required property int frameThickness
    required property int topBarHeight

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.namespace: "quickshell"

    // Only the bar accepts input. The remainder of this monitor-sized surface
    // is visual, so clicks pass through to windows and the desktop below it.
    mask: Region {
        item: topBar
    }

    TopBar {
        id: topBar

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        implicitHeight: frame.topBarHeight
        barHeight: frame.topBarHeight
        glassColor: frame.fillColor
    }

    Rectangle {
        anchors {
            top: topBar.bottom
            left: parent.left
            bottom: bottomEdge.top
        }

        width: frame.frameThickness
        color: frame.fillColor
    }

    Rectangle {
        anchors {
            top: topBar.bottom
            right: parent.right
            bottom: bottomEdge.top
        }

        width: frame.frameThickness
        color: frame.fillColor
    }

    Rectangle {
        id: bottomEdge

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: frame.frameThickness
        color: frame.fillColor
    }

    ConcaveCorner {
        corner: ConcaveCorner.TopLeft
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        x: frame.frameThickness
        y: frame.topBarHeight
    }

    ConcaveCorner {
        corner: ConcaveCorner.TopRight
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        x: frame.width - frame.frameThickness - width
        y: frame.topBarHeight
    }

    ConcaveCorner {
        corner: ConcaveCorner.BottomLeft
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        x: frame.frameThickness
        y: frame.height - frame.frameThickness - height
    }

    ConcaveCorner {
        corner: ConcaveCorner.BottomRight
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        x: frame.width - frame.frameThickness - width
        y: frame.height - frame.frameThickness - height
    }
}

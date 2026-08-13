import QtQuick
import Quickshell

ShellRoot {
    id: frame

    required property color fillColor
    required property int cornerRadius
    required property int frameThickness
    required property int topBarHeight

    TopBar {
        barHeight: frame.topBarHeight
        color: frame.fillColor
    }

    Edge {
        side: Edge.Left
        thickness: frame.frameThickness
        color: frame.fillColor
    }

    Edge {
        side: Edge.Right
        thickness: frame.frameThickness
        color: frame.fillColor
    }

    Edge {
        side: Edge.Bottom
        thickness: frame.frameThickness
        color: frame.fillColor
    }

    ConcaveCorner {
        corner: ConcaveCorner.TopLeft
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        frameThickness: frame.frameThickness
    }

    ConcaveCorner {
        corner: ConcaveCorner.TopRight
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        frameThickness: frame.frameThickness
    }

    ConcaveCorner {
        corner: ConcaveCorner.BottomLeft
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        frameThickness: frame.frameThickness
    }

    ConcaveCorner {
        corner: ConcaveCorner.BottomRight
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        frameThickness: frame.frameThickness
    }
}

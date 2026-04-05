import QtQuick
import Quickshell

ShellRoot {
    id: frame

    required property color fillColor
    required property int cornerRadius
    required property int frameThickness
    required property int topBarHeight

    TopBar { 
        height: topBarHeight
        color: fillColor
    }

    Edge {
        side: Edge.Left
        thickness: frameThickness
        color: fillColor
    }

    Edge {
        side: Edge.Right
        thickness: frameThickness
        color: fillColor
    }

    Edge {
        side: Edge.Bottom
        thickness: frameThickness
        color: fillColor
    }

    ConcaveCorner {
        corner: ConcaveCorner.TopLeft
        radius: cornerRadius
        fillColor: frame.fillColor
        frameThickness: frame.frameThickness
    }

    ConcaveCorner {
        corner: ConcaveCorner.TopRight
        radius: cornerRadius
        fillColor: frame.fillColor
        frameThickness: frame.frameThickness
    }

    ConcaveCorner {
        corner: ConcaveCorner.BottomLeft
        radius: cornerRadius
        fillColor: frame.fillColor
        frameThickness: frame.frameThickness
    }

    ConcaveCorner {
        corner: ConcaveCorner.BottomRight
        radius: cornerRadius
        fillColor: frame.fillColor
        frameThickness: frame.frameThickness
    }
}

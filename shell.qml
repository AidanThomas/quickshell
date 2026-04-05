import "components"
import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell

ShellRoot {
    id: root

    property color frameColor: "#1e1e2e"
    property int cornerRadius: 10 
    property int frameThickness: 5 
    property int topBarHeight: 40

    Frame {
        cornerRadius: root.cornerRadius
        fillColor: root.frameColor
        frameThickness: root.frameThickness
        topBarHeight: root.topBarHeight
    }
}

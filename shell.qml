import qs.components
import qs.config

import QtQuick
import Quickshell

ShellRoot {
    id: root

    property color frameColor: Theme.background
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

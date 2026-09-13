import qs.components
import qs.config

import QtQuick
import Quickshell

ShellRoot {
    id: root

    TopBar {
        barHeight: 40
        color: Theme.background
    }

    ConcaveCorner {
        corner: ConcaveCorner.TopLeft
        radius: 10
        fillColor: Theme.background
        frameThickness: 0
    }

    ConcaveCorner {
        corner: ConcaveCorner.TopRight
        radius: 10
        fillColor: Theme.background
        frameThickness: 0
    }
}

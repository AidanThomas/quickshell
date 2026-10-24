import qs.components
import qs.config

import QtQuick
import Quickshell

ShellRoot {
    id: root

    Frame {
        fillColor: Theme.glassFrameSurface
        cornerRadius: 18
        topBarHeight: 52
    }

    FrameReservation {
        reservedHeight: 52
    }
}

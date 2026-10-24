import qs.components
import qs.config

import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    Frame {
        fillColor: Theme.glassFrameSurface
        cornerRadius: 18
        topBarHeight: 52
    }

    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        // Reserve room for the bar without adding a second visible glass
        // surface or making the monitor-sized frame exclusive.
        implicitHeight: 1
        exclusiveZone: 52
        color: "transparent"

        mask: Region {
            width: 0
            height: 0
        }

        WlrLayershell.namespace: "quickshell:frame-reservation"
    }
}

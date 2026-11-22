import qs.components
import qs.config

import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    Variants {
        model: LayoutPolicy.primaryScreens(Quickshell.screens)

        Frame {
            required property ShellScreen modelData

            output: modelData
            fillColor: Theme.glassFrameSurface
            cornerRadius: 18
            topBarHeight: Theme.topBarHeight
        }
    }

    Variants {
        model: LayoutPolicy.primaryScreens(Quickshell.screens)

        PanelWindow {
            required property ShellScreen modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            // Reserve room for the bar without adding a second visible glass
            // surface or making the monitor-sized frame exclusive.
            implicitHeight: 1
            exclusiveZone: Theme.topBarHeight
            color: "transparent"

            mask: Region {
                width: 0
                height: 0
            }

            WlrLayershell.namespace: "quickshell:frame-reservation"
        }
    }

    Variants {
        model: LayoutPolicy.secondaryScreens(Quickshell.screens)

        SecondaryBar {
            required property ShellScreen modelData
            output: modelData
        }
    }
}

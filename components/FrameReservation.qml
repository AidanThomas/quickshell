import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property int reservedHeight

    anchors {
        top: true
        left: true
        right: true
    }

    // A minimal, fully transparent layer surface owns the exclusive zone.
    // Keeping it separate lets the visible frame cover the monitor without
    // reserving the whole screen or creating another glass boundary.
    implicitHeight: 1
    exclusiveZone: reservedHeight
    color: "transparent"

    mask: Region {
        width: 0
        height: 0
    }

    WlrLayershell.namespace: "quickshell:frame-reservation"
}

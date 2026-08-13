import Quickshell

PanelWindow {
    enum Side {
        Top,
        Left,
        Right,
        Bottom
    }

    required property int side
    required property int thickness
    required color

    exclusionMode: ExclusionMode.Normal

    anchors {
        top: side === 0 || side === 1 || side == 2
        left: side === 0 || side === 1 || side == 3
        right: side === 0 || side === 2 || side === 3
        bottom: side === 1 || side === 2 || side === 3
    }

    implicitHeight: side === 0 || side === 3 ? thickness : 0
    implicitWidth: side === 1 || side === 2 ? thickness : 0
}

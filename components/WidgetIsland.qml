import qs.config

import QtQuick

Item {
    id: root

    default property alias content: contentContainer.data

    property int horizontalPadding: Theme.islandPaddingHorizontal
    property int verticalPadding: Theme.islandPaddingVertical

    property bool hoverEnabled: true
    property bool active: false
    property bool attention: false
    property bool critical: false
    property bool keyboardFocused: false
    property bool muted: false
    property bool fullWidthAccent: false

    property bool accentVisible: active || attention || critical || keyboardFocused
    property color accentColor: critical
        ? Theme.accentRed
        : (attention ? Theme.accentAmber : Theme.accentCyan)
    property color surfaceColor: active || keyboardFocused
        ? Theme.islandSurfaceActive
        : (hovered ? Theme.islandSurfaceHover : Theme.islandSurface)
    property color outlineColor: critical
        ? Theme.accentRed
        : ((keyboardFocused || hovered) ? Theme.borderHover : Theme.borderDefault)

    readonly property bool hovered: hoverEnabled && hoverHandler.hovered

    implicitWidth: contentContainer.implicitWidth + horizontalPadding * 2
    implicitHeight: Theme.islandHeight
    opacity: !enabled ? 0.45 : (muted ? 0.68 : 1)

    TechnicalSurface {
        anchors.fill: parent
        cutSize: Theme.surfaceCutSize
        fillColor: root.surfaceColor
        outlineWidth: Theme.islandBorderWidth
        outlineColor: root.outlineColor
    }

    Item {
        id: contentContainer

        anchors.centerIn: parent
        width: implicitWidth
        height: implicitHeight
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }

    Rectangle {
        id: accent

        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: Theme.surfaceCutSize
        }

        width: root.fullWidthAccent
            ? Math.max(0, root.width - Theme.surfaceCutSize * 2)
            : Math.min(18, Math.max(0, root.width - Theme.surfaceCutSize * 2))
        height: 1
        color: root.accentColor
        opacity: root.accentVisible ? 1 : 0

        Behavior on color {
            ColorAnimation {
                duration: Theme.animationState
                easing.type: Theme.easingStandard
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: Theme.animationState
                easing.type: Theme.easingStandard
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animationState
                easing.type: Theme.easingStandard
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        enabled: root.enabled && root.hoverEnabled
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animationState
            easing.type: Theme.easingStandard
        }
    }
}

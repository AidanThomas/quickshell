import qs.config

import QtQuick

Item {
    id: root

    default property alias content: contentContainer.data

    property int horizontalPadding: Theme.islandPaddingHorizontal
    property int verticalPadding: Theme.islandPaddingVertical

    property bool hoverEnabled: true
    property bool active: false
    property bool pressed: false
    property bool attention: false
    property bool critical: false
    property bool keyboardFocused: false
    property bool muted: false
    property bool loading: false
    property bool unavailable: false
    property bool fullWidthAccent: false

    property bool accentVisible: active || attention || critical || keyboardFocused
    property color accentColor: critical
        ? Theme.accentRed
        : (attention ? Theme.accentAmber : Theme.accentCyan)
    property color surfaceColor: active || pressed || keyboardFocused
        ? Theme.islandSurfaceActive
        : (hovered ? Theme.islandSurfaceHover : Theme.islandSurface)
    property color outlineColor: critical
        ? Theme.accentRed
        : ((keyboardFocused || hovered) ? Theme.borderHover : Theme.borderDefault)

    property bool hovered: hoverEnabled && hoverHandler.hovered
    property real entranceProgress: 0

    implicitWidth: contentContainer.implicitWidth + horizontalPadding * 2
    implicitHeight: Theme.islandHeight
    opacity: entranceProgress * ((!enabled || unavailable) ? 0.45 : ((muted || loading) ? 0.68 : 1))
    scale: entranceProgress
    transformOrigin: Item.Center

    Component.onCompleted: entranceAnimation.start()

    NumberAnimation {
        id: entranceAnimation
        target: root
        property: "entranceProgress"
        from: 0
        to: 1
        duration: Theme.animationEntrance
        easing.type: Theme.easingEntrance
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: -2
        anchors.rightMargin: -2
        anchors.topMargin: 2
        anchors.bottomMargin: -3
        radius: Theme.islandRadius + 2
        color: Theme.shadowColor
        opacity: root.hovered ? 0.8 : 0.52

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationHover }
        }
    }

    TechnicalSurface {
        anchors.fill: parent
        cutSize: Theme.surfaceCutSize
        fillColor: root.surfaceColor
        outlineWidth: Theme.islandBorderWidth
        outlineColor: root.outlineColor
        radius: Theme.islandRadius
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
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 2
        }

        width: root.fullWidthAccent ? Math.max(0, root.width - 18) : 20
        height: 2
        color: root.accentColor
        radius: 1
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

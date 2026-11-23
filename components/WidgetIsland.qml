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
    property real leadingSectionWidth: 0
    property color leadingSectionColor: "transparent"

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
    implicitWidth: contentContainer.implicitWidth + horizontalPadding * 2
    implicitHeight: Theme.islandHeight
    opacity: (!enabled || unavailable) ? 0.45 : ((muted || loading) ? 0.68 : 1)

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
            NumberAnimation {
                duration: MotionPreferences.duration(Theme.motionFeedbackDuration)
                easing.type: Theme.motionFeedbackEasing
            }
        }
    }

    Item {
        visible: root.leadingSectionWidth > 0
        anchors {
            fill: parent
            margins: Theme.islandBorderWidth
        }

        readonly property real interiorLeadingWidth: Math.max(
            0,
            Math.min(width, root.leadingSectionWidth - Theme.islandBorderWidth)
        )
        readonly property real interiorRadius: Math.max(0, Theme.islandRadius - Theme.islandBorderWidth)

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: parent.interiorLeadingWidth
            radius: parent.interiorRadius
            color: root.leadingSectionColor

            Rectangle {
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                }
                width: Math.min(parent.width, parent.parent.interiorRadius)
                color: parent.color
            }
        }

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            width: Math.max(0, parent.width - parent.interiorLeadingWidth)
            radius: parent.interiorRadius
            color: root.surfaceColor

            Rectangle {
                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }
                width: Math.min(parent.width, parent.parent.interiorRadius)
                color: parent.color
            }
        }

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            x: parent.interiorLeadingWidth - width
            width: 1
            color: root.surfaceColor
            opacity: 0.72
        }
    }

    TechnicalSurface {
        anchors.fill: parent
        cutSize: Theme.surfaceCutSize
        fillColor: root.leadingSectionWidth > 0 ? "transparent" : root.surfaceColor
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
                duration: MotionPreferences.duration(Theme.motionStateDuration)
                easing.type: Theme.motionStateEasing
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: MotionPreferences.duration(Theme.motionStateDuration)
                easing.type: Theme.motionStateEasing
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: MotionPreferences.duration(Theme.motionStateDuration)
                easing.type: Theme.motionStateEasing
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
            duration: MotionPreferences.duration(Theme.motionStateDuration)
            easing.type: Theme.motionStateEasing
        }
    }

}

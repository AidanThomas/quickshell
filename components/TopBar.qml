import qs.config
import qs.widgets

import QtQuick
import QtQuick.Layouts

Item {
    id: topBar

    required property int barHeight
    required property color glassColor

    readonly property alias leftInputRegion: leftRegion
    readonly property alias centreInputRegion: centreRegion
    readonly property alias rightInputRegion: rightRegion

    signal keyboardNavigationExitRequested

    function focusFirstInteractive() {
        if (playerIsland.visible) {
            playerIsland.forceActiveFocus(Qt.TabFocusReason);
            return;
        }

        volumeIsland.forceActiveFocus(Qt.TabFocusReason);
    }

    function clearKeyboardFocus() {
        topBar.forceActiveFocus(Qt.OtherFocusReason);
        topBar.focus = false;
    }

    implicitHeight: barHeight

    BarMaterial {
        leftTarget: leftRegion
        centreTarget: centreRegion
        rightTarget: rightRegion
        fillColor: topBar.glassColor
    }

    Item {
        id: leftRegion

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: leftContent.implicitWidth + 16

        RowLayout {
            id: leftContent

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 8
            }
            spacing: Theme.islandGap

            WidgetIsland {
                WorkspacesWidget { id: workspacesWidget }
            }

            // Ambient information belongs to the regional material without
            // pretending to be another interactive capsule.
            Item {
                implicitWidth: visualizer.implicitWidth + 12
                implicitHeight: Theme.islandHeight

                AudioVisualizerWidget {
                    id: visualizer
                    anchors.centerIn: parent
                }
            }
        }
    }

    Item {
        id: centreRegion

        readonly property bool occupied: playerWidget.hasPlayer
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        width: occupied ? playerIsland.implicitWidth + 16 : 0
        opacity: occupied ? 1 : 0

        Behavior on width {
            enabled: !MotionPreferences.reducedMotion
            NumberAnimation {
                duration: Theme.motionSpatialDuration
                easing.type: Theme.motionSpatialEasing
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: MotionPreferences.duration(Theme.motionStateDuration)
                easing.type: Theme.motionStateEasing
            }
        }

        InteractiveIsland {
            id: playerIsland

            visible: centreRegion.occupied
            anchors.centerIn: parent
            disclosure: playerWidget.disclosure
            secondaryActionEnabled: playerWidget.canTogglePlaying ?? false
            accessibleName: "Media"
            accessibleDescription: playerWidget.trackDescription ?? ""
            tooltipText: (playerWidget.canTogglePlaying ?? false)
                ? "Media — secondary click to play or pause"
                : "Media"

            onPrimaryTriggered: inputSource => playerWidget.togglePopup(inputSource)
            onSecondaryTriggered: playerWidget.togglePlaying()
            onEscapeRequested: playerWidget.closePopup(DisclosureLifecycle.Escape, DisclosureLifecycle.Keyboard)

            PlayerWidget {
                id: playerWidget
                popupOrigin: playerIsland
            }
        }
    }

    Item {
        id: rightRegion

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: rightContent.implicitWidth + 16

        RowLayout {
            id: rightContent

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 8
            }
            spacing: Theme.islandGap

            WidgetIsland {
                id: notificationIsland

                active: notificationWidget.popupOpen
                attention: notificationWidget.unreadCount > 0
                critical: notificationWidget.hasUrgent
                muted: notificationWidget.doNotDisturb

                NotificationWidget {
                    id: notificationWidget
                    popupOrigin: notificationIsland
                }
            }

            InteractiveIsland {
                id: volumeIsland

                open: volumeWidget.popupOpen
                attention: volumeWidget.inputMuted || volumeWidget.outputMuted
                fullWidthAccent: volumeWidget.popupOpen
                wheelActionEnabled: volumeWidget.outputAvailable ?? false
                accessibleName: "Audio"
                accessibleDescription: volumeWidget.statusDescription ?? ""
                tooltipEnabled: !(volumeWidget.childActionHovered ?? false)
                tooltipText: (volumeWidget.outputAvailable ?? false)
                    ? "Audio — scroll to adjust output volume"
                    : "Audio unavailable"

                onPrimaryTriggered: volumeWidget.togglePopup()
                onWheelAdjusted: steps => volumeWidget.adjustOutputVolume(steps)
                onEscapeRequested: volumeWidget.closePopup()

                VolumeWidget {
                    id: volumeWidget

                    onPopupEscapeDismissed: volumeIsland.forceActiveFocus(Qt.TabFocusReason)
                }
            }

            WidgetIsland {
                hoverEnabled: false
                horizontalPadding: 9

                ClockWidget {}
            }
        }
    }

    Keys.onEscapePressed: event => {
        keyboardNavigationExitRequested();
        event.accepted = true;
    }
}

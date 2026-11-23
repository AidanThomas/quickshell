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

    readonly property int layoutMode: LayoutPolicy.modeForWidth(width)

    function focusFirstInteractive() {
        workspacesWidget.forceActiveFocus(Qt.TabFocusReason);
    }

    function clearKeyboardFocus() {
        topBar.forceActiveFocus(Qt.OtherFocusReason);
        topBar.focus = false;
    }

    implicitHeight: barHeight

    function canopyRect(): rect {
        const presenter = CanopyDisclosure.presenter;
        if (!presenter || !presenter.canopyPresentationActive)
            return Qt.rect(0, 0, 0, 0);

        const surface = presenter.canopySurfaceRect;
        const topLeft = topBar.mapFromGlobal(Qt.point(surface.x, surface.y));
        const backingMargin = Theme.canopyBackingMargin;
        return Qt.rect(
            topLeft.x - backingMargin,
            topLeft.y - backingMargin,
            surface.width + backingMargin * 2,
            surface.height + backingMargin * 2
        );
    }

    function canopyOriginRect(): rect {
        const presenter = CanopyDisclosure.presenter;
        if (!presenter || !presenter.canopyPresentationActive)
            return Qt.rect(0, 0, 0, 0);

        const origin = presenter.canopyOriginRect;
        const topLeft = topBar.mapFromGlobal(Qt.point(origin.x, origin.y));
        return Qt.rect(topLeft.x, topLeft.y, origin.width, origin.height);
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
                id: workspaceIsland

                keyboardFocused: workspacesWidget.activeFocus
                leadingSectionWidth: horizontalPadding + workspacesWidget.attachmentWidth
                leadingSectionColor: Theme.secondarySurface

                WorkspacesWidget { id: workspacesWidget }
            }

            // Ambient information belongs to the regional material without
            // pretending to be another interactive capsule.
            Item {
                visible: topBar.layoutMode === LayoutPolicy.Full
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
            && topBar.layoutMode !== LayoutPolicy.Minimum
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

            InteractiveIsland {
                id: notificationIsland

                visible: topBar.layoutMode !== LayoutPolicy.Minimum
                    || notificationWidget.unreadCount > 0
                    || notificationWidget.hasUrgent
                    || notificationWidget.doNotDisturb

                disclosure: notificationWidget.disclosure
                attention: notificationWidget.unreadCount > 0
                critical: notificationWidget.hasUrgent
                muted: notificationWidget.doNotDisturb
                secondaryActionEnabled: true
                accessibleName: "Notifications"
                accessibleDescription: notificationWidget.statusDescription ?? ""
                tooltipText: "Notifications — secondary click toggles do not disturb"

                onPrimaryTriggered: inputSource => notificationWidget.activate(inputSource)
                onSecondaryTriggered: notificationWidget.toggleDoNotDisturb()
                onEscapeRequested: notificationWidget.disclosure.requestClose(
                    DisclosureLifecycle.Escape,
                    DisclosureLifecycle.Keyboard
                )

                NotificationWidget {
                    id: notificationWidget
                    popupOrigin: notificationIsland
                }
            }

            InteractiveIsland {
                id: volumeIsland

                disclosure: volumeWidget.disclosure
                attention: volumeWidget.inputMuted || volumeWidget.outputMuted
                fullWidthAccent: volumeWidget.popupOpen
                wheelActionEnabled: volumeWidget.outputAvailable ?? false
                accessibleName: "Audio"
                accessibleDescription: volumeWidget.statusDescription ?? ""
                tooltipEnabled: !(volumeWidget.childActionHovered ?? false)
                tooltipText: (volumeWidget.outputAvailable ?? false)
                    ? "Audio — scroll to adjust output volume"
                    : "Audio unavailable"

                onPrimaryTriggered: inputSource => volumeWidget.togglePopup(inputSource)
                onWheelAdjusted: steps => volumeWidget.adjustOutputVolume(steps)
                onEscapeRequested: volumeWidget.closePopup(
                    DisclosureLifecycle.Escape,
                    DisclosureLifecycle.Keyboard
                )

                VolumeWidget {
                    id: volumeWidget
                    popupOrigin: volumeIsland
                }
            }

            InteractiveIsland {
                id: clockIsland

                horizontalPadding: 14
                disclosure: clockWidget.disclosure
                accessibleName: "Clock and calendar"
                tooltipText: "Open calendar"

                onPrimaryTriggered: inputSource => clockWidget.toggleCalendar(inputSource)
                onEscapeRequested: clockWidget.closeCalendar(
                    DisclosureLifecycle.Escape,
                    DisclosureLifecycle.Keyboard
                )

                ClockWidget {
                    id: clockWidget
                    popupOrigin: clockIsland
                }
            }
        }
    }

    Keys.onEscapePressed: event => {
        keyboardNavigationExitRequested();
        event.accepted = true;
    }
}

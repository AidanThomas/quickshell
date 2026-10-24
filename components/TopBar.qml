import qs.config
import qs.widgets

import QtQuick
import QtQuick.Layouts

Item {
    id: topBar

    required property int barHeight
    required property color glassColor

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

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: topBar.glassColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: Theme.islandGap

        WidgetIsland {
            active: workspacesWidget.moving

            WorkspacesWidget { id: workspacesWidget }
        }

        WidgetIsland {
            hoverEnabled: false
            horizontalPadding: 8

            AudioVisualizerWidget {}
        }

        Item {
            Layout.fillWidth: true
        }

        InteractiveIsland {
            id: playerIsland

            visible: playerWidget.hasPlayer
            open: playerWidget.popupOpen
            secondaryActionEnabled: playerWidget.canTogglePlaying ?? false
            accessibleName: "Media"
            accessibleDescription: playerWidget.trackDescription ?? ""
            tooltipText: (playerWidget.canTogglePlaying ?? false)
                ? "Media — secondary click to play or pause"
                : "Media"

            onPrimaryTriggered: playerWidget.togglePopup()
            onSecondaryTriggered: playerWidget.togglePlaying()
            onEscapeRequested: playerWidget.closePopup()

            PlayerWidget {
                id: playerWidget

                onPopupEscapeDismissed: playerIsland.forceActiveFocus(Qt.TabFocusReason)
            }
        }

        Item {
            Layout.fillWidth: true
        }

        WidgetIsland {
            active: notificationWidget.popupOpen
            attention: notificationWidget.unreadCount > 0
            critical: notificationWidget.hasUrgent
            muted: notificationWidget.doNotDisturb

            NotificationWidget {
                id: notificationWidget
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

    Keys.onEscapePressed: event => {
        keyboardNavigationExitRequested();
        event.accepted = true;
    }
}

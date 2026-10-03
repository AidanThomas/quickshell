import qs.config
import qs.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: topBar

    required property int barHeight
    required color

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: barHeight

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
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

        WidgetIsland {
            visible: playerWidget.hasPlayer
            active: playerWidget.popupOpen

            PlayerWidget {
                id: playerWidget
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

        WidgetIsland {
            active: volumeWidget.popupOpen
            attention: volumeWidget.inputMuted || volumeWidget.outputMuted
            fullWidthAccent: volumeWidget.popupOpen

            VolumeWidget {
                id: volumeWidget
            }
        }

        WidgetIsland {
            hoverEnabled: false
            horizontalPadding: 9

            ClockWidget {}
        }
    }
}

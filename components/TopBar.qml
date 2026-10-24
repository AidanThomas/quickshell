import qs.config
import qs.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: topBar

    required property int barHeight
    required property color glassColor

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: barHeight

    color: "transparent"

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

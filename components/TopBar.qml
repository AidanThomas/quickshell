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
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        WorkspacesWidget {}
        AudioVisualizerWidget {}

        Item {
            Layout.fillWidth: true
        }

        PlayerWidget {}

        Item {
            Layout.fillWidth: true
        }

        NotificationWidget {}
        VolumeWidget {}
        ClockWidget {}
    }
}

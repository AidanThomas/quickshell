import "../widgets"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: topBar

    required property int height
    required color

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: height

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        WorkspacesWidget {}

        Item {
            Layout.fillWidth: true
        }

        WindowTitleWidget {}

        Item {
            Layout.fillWidth: true
        }

        ClockWidget {}
    }
}

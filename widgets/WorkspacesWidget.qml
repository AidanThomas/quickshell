import QtQuick
import Quickshell.Hyprland

Rectangle {
    implicitHeight: workspacesRow.implicitHeight
    implicitWidth: workspacesRow.implicitWidth
    color: "transparent"

    Row {
        id: workspacesRow
        spacing: 10

        Repeater {
            id: workspace
            model: 5

            Text {
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                text: index + 1
                color: isActive ? "#0db9d7" : (ws ? "#7aa2f7": "#444b6a")
                font: { pixelSize: 14; bold: true }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }
    }
}

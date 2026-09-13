pragma ComponentBehavior: Bound
import qs.config

import QtQuick
import Quickshell.Hyprland

Rectangle {
    id: root

    readonly property var workspaceNames: ["terminal", "browser", "steam", "files", "music", "6", "7", "8", "9", "10"]
    readonly property string activeWorkspaceName: Hyprland.focusedWorkspace?.name ?? ""
    readonly property int activeWorkspaceIndex: workspaceNames.indexOf(activeWorkspaceName)
    readonly property int highestOccupiedWorkspaceIndex: {
        let highestIndex = -1;

        for (let index = 5; index < workspaceNames.length; index++) {
            const workspace = Hyprland.workspaces.values.find(candidate => candidate.name === workspaceNames[index]);

            if ((workspace?.toplevels.values.length ?? 0) > 0)
                highestIndex = index;
        }

        return highestIndex;
    }
    readonly property int visibleWorkspaceCount: Math.max(5, activeWorkspaceIndex + 1, highestOccupiedWorkspaceIndex + 1)
    readonly property int indicatorSize: 14
    readonly property int indicatorSlotWidth: 16
    readonly property int indicatorSpacing: 4

    implicitHeight: workspacesRow.implicitHeight
    implicitWidth: workspacesRow.implicitWidth
    color: "transparent"

    Row {
        id: workspacesRow
        spacing: root.indicatorSpacing

        Repeater {
            id: workspace
            model: root.visibleWorkspaceCount

            Item {
                id: workspaceIndicator
                required property int index
                property var hyprWorkspace: Hyprland.workspaces.values.find(workspace => workspace.name === root.workspaceNames[index])
                property bool isActive: root.activeWorkspaceIndex === index
                property bool isOccupied: (hyprWorkspace?.toplevels.values.length ?? 0) > 0

                implicitWidth: root.indicatorSlotWidth
                implicitHeight: 24

                Rectangle {
                    anchors.centerIn: parent
                    width: root.indicatorSize
                    height: root.indicatorSize
                    radius: width / 2
                    color: "transparent"
                    border.width: 1
                    border.color: workspaceIndicator.isActive ? Theme.workspaceActive : (workspaceIndicator.isOccupied ? Theme.workspaceOccupied : Theme.workspaceEmpty)
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = \"" + (workspaceIndicator.index + 1) + "\" })")
                }
            }
        }
    }

    Rectangle {
        id: activeIndicator

        visible: root.activeWorkspaceIndex >= 0
        property real centerPosition: 0
        property int movementDirection: 0
        property bool initialized: false

        function moveToWorkspace(index) {
            const targetPosition = index * (root.indicatorSlotWidth + root.indicatorSpacing) + root.indicatorSlotWidth / 2;

            movementDirection = targetPosition > centerPosition ? 1 : -1;
            centerPosition = targetPosition;
        }

        width: movementAnimation.running ? root.indicatorSize + 10 : root.indicatorSize
        height: root.indicatorSize
        radius: height / 2
        x: movementDirection > 0 ? centerPosition - width + height / 2 : centerPosition - height / 2
        anchors.verticalCenter: workspacesRow.verticalCenter
        color: Theme.workspaceActive

        Component.onCompleted: {
            centerPosition = root.activeWorkspaceIndex * (root.indicatorSlotWidth + root.indicatorSpacing) + root.indicatorSlotWidth / 2;
            initialized = true;
        }

        Connections {
            target: root

            function onActiveWorkspaceIndexChanged() {
                if (root.activeWorkspaceIndex >= 0)
                    activeIndicator.moveToWorkspace(root.activeWorkspaceIndex);
            }
        }

        Behavior on centerPosition {
            enabled: activeIndicator.initialized

            NumberAnimation {
                id: movementAnimation
                duration: 150
                easing.type: Easing.InOutSine
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 140
                easing.type: Easing.InOutSine
            }
        }
    }
}

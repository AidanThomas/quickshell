pragma ComponentBehavior: Bound
import qs.config

import QtQuick
import QtQuick.Controls as Controls
import Quickshell.Hyprland

FocusScope {
    id: root

    readonly property var preferredWorkspaceNames: ["terminal", "browser", "steam", "files", "music"]
    readonly property var excludedWorkspaceIds: [11]
    readonly property var workspaceEntries: {
        const liveWorkspaces = Array.from(Hyprland.workspaces.values ?? [])
            .filter(workspace => !root.excludedWorkspaceIds.includes(workspace.id));
        const entries = root.preferredWorkspaceNames.map((name, index) => ({
            name,
            position: index + 1,
            workspace: liveWorkspaces.find(workspace => workspace.name === name) ?? null
        }));
        const extras = liveWorkspaces
            .filter(workspace => !root.preferredWorkspaceNames.includes(workspace.name))
            .filter(workspace => !workspace.name.startsWith("special:"))
            .sort((left, right) => {
                if (left.id >= 0 && right.id >= 0)
                    return left.id - right.id;
                return left.name.localeCompare(right.name);
            });

        for (const workspace of extras) {
            entries.push({
                name: workspace.name,
                position: workspace.id > 0 ? workspace.id : entries.length + 1,
                workspace
            });
        }
        return entries;
    }
    readonly property string activeWorkspaceName: {
        const focused = Hyprland.focusedWorkspace;
        if (focused && !root.excludedWorkspaceIds.includes(focused.id))
            return focused.name;

        const activeWorkspace = Array.from(Hyprland.workspaces.values ?? [])
            .find(workspace => workspace.active && !root.excludedWorkspaceIds.includes(workspace.id));
        return activeWorkspace?.name ?? "";
    }
    readonly property int activeWorkspaceIndex: workspaceEntries.findIndex(entry => entry.name === activeWorkspaceName)
    readonly property int navigationIndex: activeWorkspaceIndex >= 0 ? activeWorkspaceIndex : 0
    readonly property int indicatorSize: 10
    readonly property int selectedIndicatorWidth: 22
    readonly property int indicatorSlotWidth: 28
    readonly property int indicatorSpacing: 2
    readonly property int attachmentWidth: 38
    readonly property int transitionDuration: 300
    readonly property real railContentWidth: workspaceEntries.length * indicatorSlotWidth
        + Math.max(0, workspaceEntries.length - 1) * indicatorSpacing
    readonly property bool moving: transitionAnimation.running
    readonly property string activeDisplayNumber: activeWorkspaceIndex >= 0
        ? String(activeWorkspaceIndex + 1).padStart(2, "0")
        : "--"
    readonly property string activeDescription: {
        const entry = workspaceEntries[activeWorkspaceIndex];
        if (!entry)
            return "Workspace state unavailable";
        const count = entry.workspace?.toplevels.values.length ?? 0;
        return root.displayName(entry.name) + ", selected, " + root.windowCountText(count);
    }

    property real wheelRemainder: 0
    property real transitionProgress: 1
    property real markerStartHead: 0
    property real markerStartTail: 0
    property real markerStartBaseWidth: selectedIndicatorWidth
    property real markerTargetCenter: 0
    property bool visualReady: false

    function clamp(value: real, minimum: real, maximum: real): real {
        return Math.max(minimum, Math.min(maximum, value));
    }

    function smooth(value: real): real {
        const t = clamp(value, 0, 1);
        return t * t * (3 - 2 * t);
    }

    function phase(value: real, start: real, end: real): real {
        return smooth((value - start) / (end - start));
    }

    function mix(from: real, to: real, progress: real): real {
        return from + (to - from) * progress;
    }

    function accentWithAlpha(alpha: real): color {
        return Qt.rgba(Theme.accentCyan.r, Theme.accentCyan.g, Theme.accentCyan.b, alpha);
    }

    function normalCenter(index: int): real {
        return index * (indicatorSlotWidth + indicatorSpacing) + indicatorSlotWidth / 2;
    }

    function markerBaseWidth(): real {
        if (transitionProgress < 0.22)
            return mix(markerStartBaseWidth, indicatorSize, phase(transitionProgress, 0, 0.22));
        if (transitionProgress < 0.7)
            return indicatorSize;
        return mix(indicatorSize, selectedIndicatorWidth, phase(transitionProgress, 0.7, 1));
    }

    function initializeVisuals(): void {
        const selected = activeWorkspaceIndex;
        markerTargetCenter = selected >= 0 ? normalCenter(selected) : 0;
        markerStartHead = markerTargetCenter;
        markerStartTail = markerTargetCenter;
        markerStartBaseWidth = selectedIndicatorWidth;
        transitionProgress = 1;
        visualReady = true;
    }

    function transitionTo(index: int): void {
        if (!visualReady || index < 0)
            return;

        transitionAnimation.stop();
        markerStartHead = activeIndicator.headPosition;
        markerStartTail = activeIndicator.tailPosition;
        markerStartBaseWidth = activeIndicator.baseWidth;
        markerTargetCenter = normalCenter(index);
        transitionProgress = 0;

        if (MotionPreferences.reducedMotion) {
            transitionProgress = 1;
            return;
        }

        transitionAnimation.restart();
        readoutPulse.restart();
    }

    function displayName(name: string): string {
        if (!name)
            return "Workspace";
        const normalized = name.startsWith("name:") ? name.slice(5) : name;
        return normalized.charAt(0).toUpperCase() + normalized.slice(1);
    }

    function windowCountText(count: int): string {
        if (count === 0)
            return "empty";
        return count + (count === 1 ? " window" : " windows");
    }

    function entryDescription(entry: var): string {
        const count = entry.workspace?.toplevels.values.length ?? 0;
        const states = [];
        if (entry.name === root.activeWorkspaceName)
            states.push("current");
        if (entry.workspace?.urgent ?? false)
            states.push("attention");
        states.push(root.windowCountText(count));
        return root.displayName(entry.name) + " · " + states.join(" · ");
    }

    function activateIndex(index: int): void {
        if (index < 0 || index >= workspaceEntries.length)
            return;
        const entry = workspaceEntries[index];
        if (entry.workspace)
            entry.workspace.activate();
        else
            Hyprland.dispatch("hl.dsp.focus({ workspace = \"" + entry.position + "\" })");
    }

    function navigate(offset: int): void {
        if (workspaceEntries.length === 0)
            return;
        const target = Math.max(0, Math.min(workspaceEntries.length - 1, navigationIndex + offset));
        if (target !== navigationIndex)
            activateIndex(target);
    }

    implicitHeight: contentRow.implicitHeight
    implicitWidth: contentRow.implicitWidth
    activeFocusOnTab: true

    Accessible.role: Accessible.List
    Accessible.name: "Workspaces"
    Accessible.description: activeDescription
    Accessible.focusable: true
    Accessible.focused: activeFocus

    Component.onCompleted: Qt.callLater(root.initializeVisuals)
    onWorkspaceEntriesChanged: {
        if (visualReady)
            Qt.callLater(root.initializeVisuals);
    }

    Connections {
        target: root
        function onActiveWorkspaceIndexChanged(): void {
            root.transitionTo(root.activeWorkspaceIndex);
        }
    }

    NumberAnimation {
        id: transitionAnimation
        target: root
        property: "transitionProgress"
        from: 0
        to: 1
        duration: root.transitionDuration
        easing.type: Easing.Linear
    }

    Row {
        id: contentRow
        spacing: 0

        Item {
            implicitWidth: root.attachmentWidth
            implicitHeight: 32

            Text {
                id: readoutText
                anchors.centerIn: parent
                text: root.activeDisplayNumber
                color: Theme.textPrimary
                font {
                    family: Theme.fontFamily
                    pixelSize: 11
                    weight: Font.Medium
                    letterSpacing: 0.8
                }
            }
        }

        Item {
            id: railContainer
            implicitWidth: root.railContentWidth + 16
            implicitHeight: 32

            Item {
                id: workspaceLayer
                x: 8
                width: root.railContentWidth
                height: parent.height

                Repeater {
                    id: workspacesRepeater
                    model: root.workspaceEntries

                    Item {
                        id: workspaceIndicator
                        required property int index
                        required property var modelData
                        readonly property var hyprWorkspace: modelData.workspace
                        readonly property bool isActive: modelData.name === root.activeWorkspaceName
                        readonly property bool isOccupied: (hyprWorkspace?.toplevels.values.length ?? 0) > 0
                        readonly property bool isUrgent: hyprWorkspace?.urgent ?? false
                        readonly property bool hasFullscreen: hyprWorkspace?.hasFullscreen ?? false

                        x: root.normalCenter(index) - width / 2
                        width: 24
                        height: 32

                        Rectangle {
                            id: workspaceMark
                            anchors.centerIn: parent
                            width: root.indicatorSize
                            height: root.indicatorSize
                            radius: width / 2
                            color: "transparent"
                            border.width: workspaceIndicator.isOccupied ? 1.5 : 1
                            border.color: workspaceIndicator.isOccupied ? Theme.accentBlue : Theme.borderSubtle

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: MotionPreferences.duration(Theme.motionStateDuration)
                                    easing.type: Theme.motionStateEasing
                                }
                            }
                        }

                        Item {
                            visible: workspaceIndicator.isUrgent && !workspaceIndicator.isActive
                            anchors {
                                right: workspaceMark.right
                                top: workspaceMark.top
                                rightMargin: -4
                                topMargin: -4
                            }
                            width: 6
                            height: 6

                            Rectangle {
                                id: urgentGlow
                                anchors.centerIn: parent
                                width: 9
                                height: 9
                                radius: 2
                                rotation: 45
                                color: Theme.accentAmber
                                opacity: 0
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                width: 5
                                height: 5
                                radius: 1
                                rotation: 45
                                color: Theme.accentAmber
                            }
                        }

                        Item {
                            visible: workspaceIndicator.hasFullscreen && workspaceIndicator.isOccupied
                            anchors {
                                left: workspaceMark.left
                                bottom: workspaceMark.bottom
                                leftMargin: -4
                                bottomMargin: -4
                            }
                            width: 6
                            height: 6

                            Rectangle {
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                width: 5
                                height: 1
                                color: Theme.accentBlue
                            }
                            Rectangle {
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                width: 1
                                height: 5
                                color: Theme.accentBlue
                            }
                        }

                        MouseArea {
                            id: workspaceArea
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activateIndex(workspaceIndicator.index)
                        }

                        Controls.ToolTip.visible: workspaceArea.containsMouse
                        Controls.ToolTip.text: root.entryDescription(workspaceIndicator.modelData)
                        Controls.ToolTip.delay: 650

                        SequentialAnimation {
                            id: urgencyPulse
                            NumberAnimation {
                                target: urgentGlow
                                property: "opacity"
                                from: 0
                                to: 0.5
                                duration: Theme.motionFeedbackDuration
                                easing.type: Theme.motionFeedbackEasing
                            }
                            NumberAnimation {
                                target: urgentGlow
                                property: "opacity"
                                to: 0
                                duration: Theme.motionStateDuration
                                easing.type: Theme.motionStateEasing
                            }
                        }

                        onIsUrgentChanged: {
                            if (isUrgent && !MotionPreferences.reducedMotion)
                                urgencyPulse.restart();
                        }
                    }
                }

                Item {
                    id: activeIndicator
                    readonly property real headPosition: root.mix(
                        root.markerStartHead,
                        root.markerTargetCenter,
                        root.phase(root.transitionProgress, 0.08, 0.8)
                    )
                    readonly property real tailPosition: root.mix(
                        root.markerStartTail,
                        root.markerTargetCenter,
                        root.phase(root.transitionProgress, 0.24, 0.92)
                    )
                    readonly property real baseWidth: root.markerBaseWidth()
                    readonly property real travelDistance: Math.abs(headPosition - tailPosition)
                    readonly property bool travelling: travelDistance > 0.5
                    readonly property bool travellingForward: headPosition >= tailPosition
                    readonly property real headLocalPosition: headPosition
                        - Math.min(headPosition, tailPosition)
                        + baseWidth / 2

                    visible: root.activeWorkspaceIndex >= 0
                    width: travelDistance + baseWidth
                    height: root.indicatorSize
                    x: Math.min(headPosition, tailPosition) - baseWidth / 2
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 6
                        radius: height / 2
                        opacity: activeIndicator.travelling ? 0.34 : 0

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0
                                color: activeIndicator.travellingForward
                                    ? root.accentWithAlpha(0)
                                    : Theme.accentCyan
                            }
                            GradientStop {
                                position: 1
                                color: activeIndicator.travellingForward
                                    ? Theme.accentCyan
                                    : root.accentWithAlpha(0)
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0
                                color: !activeIndicator.travelling
                                    ? Theme.accentCyan
                                    : (activeIndicator.travellingForward
                                        ? root.accentWithAlpha(0.08)
                                        : Theme.accentCyan)
                            }
                            GradientStop {
                                position: 1
                                color: !activeIndicator.travelling
                                    ? Theme.accentCyan
                                    : (activeIndicator.travellingForward
                                        ? Theme.accentCyan
                                        : root.accentWithAlpha(0.08))
                            }
                        }
                    }

                    Rectangle {
                        visible: activeIndicator.travelling
                        x: activeIndicator.headLocalPosition - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.indicatorSize
                        height: root.indicatorSize
                        radius: width / 2
                        color: Theme.accentCyan

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 5
                            height: width
                            radius: width / 2
                            color: root.accentWithAlpha(0.16)
                            z: -1
                        }
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: readoutPulse
        NumberAnimation {
            target: readoutText
            property: "opacity"
            from: 1
            to: 0.72
            duration: Theme.motionFeedbackDuration
            easing.type: Theme.motionFeedbackEasing
        }
        NumberAnimation {
            target: readoutText
            property: "opacity"
            to: 1
            duration: Theme.motionStateDuration
            easing.type: Theme.motionStateEasing
        }
    }

    Connections {
        target: MotionPreferences
        function onReducedMotionChanged(): void {
            if (!MotionPreferences.reducedMotion)
                return;
            transitionAnimation.stop();
            readoutPulse.stop();
            readoutText.opacity = 1;
            root.initializeVisuals();
        }
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        target: null
        onWheel: event => {
            let delta = event.angleDelta.y / 120;
            if (delta === 0 && event.pixelDelta.y !== 0)
                delta = event.pixelDelta.y / 40;
            root.wheelRemainder += delta;
            const steps = Math.trunc(root.wheelRemainder);
            if (steps === 0)
                return;
            root.wheelRemainder -= steps;
            root.navigate(steps > 0 ? -1 : 1);
            event.accepted = true;
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
            root.navigate(-1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
            root.navigate(1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Home) {
            root.activateIndex(0);
            event.accepted = true;
        } else if (event.key === Qt.Key_End) {
            root.activateIndex(root.workspaceEntries.length - 1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.activateIndex(root.navigationIndex);
            event.accepted = true;
        }
    }
}

import qs.config

import QtQuick
import QtQuick.Controls as Controls

FocusScope {
    id: root

    default property alias content: contentContainer.data

    property int horizontalPadding: Theme.islandPaddingHorizontal
    property int verticalPadding: Theme.islandPaddingVertical

    property bool open: false
    property bool attention: false
    property bool critical: false
    property bool muted: false
    property bool loading: false
    property bool unavailable: false
    property bool fullWidthAccent: false
    property bool secondaryActionEnabled: false
    property bool wheelActionEnabled: false

    property string accessibleName: ""
    property string accessibleDescription: ""
    property string tooltipText: ""
    property bool tooltipEnabled: true

    readonly property bool hovered: hoverHandler.hovered
    readonly property bool pressed: primaryArea.pressed || keyPressed
    readonly property bool keyboardFocused: activeFocus
    readonly property bool interactionEnabled: enabled && !loading && !unavailable

    property bool keyPressed: false

    signal primaryTriggered
    signal secondaryTriggered
    signal wheelAdjusted(real steps)
    signal escapeRequested

    implicitWidth: island.implicitWidth
    implicitHeight: island.implicitHeight
    activeFocusOnTab: enabled

    Accessible.role: Accessible.Button
    Accessible.name: accessibleName
    Accessible.description: accessibleDescription
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.pressed: pressed

    // Keep the island-level target behind the visual/content tree. Direct child
    // controls then claim their own presses without also triggering the origin,
    // while otherwise unclaimed island space falls through to this target.
    MouseArea {
        id: primaryArea

        anchors.fill: parent
        enabled: root.interactionEnabled
        acceptedButtons: Qt.LeftButton | (root.secondaryActionEnabled ? Qt.RightButton : Qt.NoButton)
        hoverEnabled: true
        cursorShape: root.interactionEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                root.secondaryTriggered();
            else
                root.primaryTriggered();
        }
    }

    WidgetIsland {
        id: island

        anchors.fill: parent
        horizontalPadding: root.horizontalPadding
        verticalPadding: root.verticalPadding
        hoverEnabled: false
        hovered: root.hovered
        active: root.open
        pressed: root.pressed
        attention: root.attention
        critical: root.critical
        keyboardFocused: root.keyboardFocused
        muted: root.muted
        loading: root.loading
        unavailable: root.unavailable
        fullWidthAccent: root.fullWidthAccent

        Item {
            id: contentContainer

            width: implicitWidth
            height: implicitHeight
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }

    HoverHandler {
        id: hoverHandler
        enabled: root.enabled
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    WheelHandler {
        // Value adjustment belongs to the island even while the pointer is over a
        // child action. IslandAction deliberately does not consume wheel events.
        enabled: root.interactionEnabled && root.wheelActionEnabled
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        target: null

        onWheel: event => {
            let steps = event.angleDelta.y / 120;
            if (steps === 0 && event.pixelDelta.y !== 0)
                steps = event.pixelDelta.y / 40;

            if (steps !== 0) {
                root.wheelAdjusted(steps);
                event.accepted = true;
            }
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape && root.open) {
            root.escapeRequested();
            event.accepted = true;
            return;
        }

        if (!root.interactionEnabled || event.isAutoRepeat)
            return;

        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.keyPressed = true;
            event.accepted = true;
        }
    }

    Keys.onReleased: event => {
        if (!root.keyPressed)
            return;

        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.keyPressed = false;
            root.primaryTriggered();
            event.accepted = true;
        }
    }

    onActiveFocusChanged: {
        if (!activeFocus)
            keyPressed = false;
    }

    Controls.ToolTip.visible: tooltipEnabled && primaryArea.containsMouse && tooltipText.length > 0
    Controls.ToolTip.text: tooltipText
    Controls.ToolTip.delay: 650
}

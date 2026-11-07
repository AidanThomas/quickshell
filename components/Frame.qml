pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: frame

    required property color fillColor
    required property int cornerRadius
    required property int topBarHeight

    property bool keyboardNavigationActive: false

    function enterKeyboardNavigation() {
        keyboardNavigationActive = true;
        Qt.callLater(() => topBar.focusFirstInteractive());
    }

    function leaveKeyboardNavigation() {
        keyboardNavigationActive = false;
        topBar.clearKeyboardFocus();
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    focusable: keyboardNavigationActive

    WlrLayershell.namespace: "quickshell"

    GlobalShortcut {
        name: "focusBar"
        description: "Focus the shell bar"

        onPressedChanged: {
            if (pressed)
                frame.enterKeyboardNavigation();
        }
    }

    IpcHandler {
        target: "bar"

        function focus(): void {
            frame.enterKeyboardNavigation();
        }

        function unfocus(): void {
            frame.leaveKeyboardNavigation();
        }
    }

    // Only occupied bar regions accept input. The connecting rail and empty
    // spans remain visual and click through to applications below.
    mask: Region {
        Region { item: topBar.leftInputRegion }
        Region {
            item: topBar.centreInputRegion
            radius: 16
        }
        Region { item: topBar.rightInputRegion }
    }

    TopBar {
        id: topBar

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        implicitHeight: frame.topBarHeight
        barHeight: frame.topBarHeight
        glassColor: frame.fillColor

        onKeyboardNavigationExitRequested: frame.leaveKeyboardNavigation()
    }

}

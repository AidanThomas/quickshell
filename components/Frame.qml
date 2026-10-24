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

    // Only the bar accepts input. The remainder of this monitor-sized surface
    // is visual, so clicks pass through to windows and the desktop below it.
    mask: Region {
        item: topBar
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

    ConcaveCorner {
        corner: ConcaveCorner.TopLeft
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        x: 0
        y: frame.topBarHeight
    }

    ConcaveCorner {
        corner: ConcaveCorner.TopRight
        radius: frame.cornerRadius
        fillColor: frame.fillColor
        x: frame.width - width
        y: frame.topBarHeight
    }
}

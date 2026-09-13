pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string fontFamily: "RobotoMono Nerd Font"

    readonly property color background: "#1e1e2e"

    readonly property color surface: "#202020"
    readonly property color surfaceRaised: "#282828"
    readonly property color surfaceHover: "#303030"

    readonly property color border: "#404040"

    readonly property color text: "white"
    readonly property color textMuted: "#a0a0a0"

    readonly property color workspaceActive: "#0db9d7"
    readonly property color workspaceOccupied: "#7aa2f7"
    readonly property color workspaceEmpty: "#444b6a"
}

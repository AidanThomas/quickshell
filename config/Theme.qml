pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string fontFamily: "RobotoMono Nerd Font Propo"
    readonly property string iconFontFamily: "RobotoMono Nerd Font"

    // Base surfaces
    readonly property color glassBarSurface: "#48111620"
    readonly property color glassFrameSurface: "#32111620"
    readonly property color islandSurface: "#B8151924"
    readonly property color islandSurfaceHover: "#D21E2433"
    readonly property color islandSurfaceActive: "#D920293A"
    readonly property color popupSurface: "#D9111621"
    readonly property color popupSurfaceRaised: "#E71C2230"
    readonly property color glassEdgeHighlight: "#30FFFFFF"
    readonly property color glassSheen: "#14FFFFFF"
    readonly property color shadowColor: "#52000000"

    // Borders
    readonly property color borderDefault: "#24FFFFFF"
    readonly property color borderHover: "#55FFFFFF"
    readonly property color borderSubtle: "#16FFFFFF"

    // Typography
    readonly property color textPrimary: "#F5F7FF"
    readonly property color textMuted: "#AAB2C5"

    // Semantic accents
    readonly property color accentCyan: "#2DEBFF"
    readonly property color accentBlue: "#7C6CFF"
    readonly property color accentAmber: "#FFCC33"
    readonly property color accentRed: "#FF4D78"

    // Ambient telemetry
    readonly property color visualizerBar: "#44D7FF"
    readonly property color visualizerPeak: "#A76BFF"

    // Shared island geometry
    readonly property int islandHeight: 36
    readonly property int islandRadius: 18
    readonly property int popupRadius: 22
    readonly property int surfaceCutSize: 0
    readonly property int islandBorderWidth: 1
    readonly property int islandPaddingHorizontal: 10
    readonly property int islandPaddingVertical: 4
    readonly property int islandGap: 10

    // Shared motion
    readonly property int animationHover: 140
    readonly property int animationState: 240
    readonly property int animationPosition: 360
    readonly property int animationEntrance: 420
    readonly property int animationVisualizer: 45
    readonly property int easingStandard: Easing.InOutCubic
    readonly property int easingEntrance: Easing.OutBack
    readonly property int easingResponsive: Easing.OutCubic

}

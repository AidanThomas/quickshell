pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string fontFamily: "Protomolecule"
    readonly property string iconFontFamily: "RobotoMono Nerd Font"

    // Base surfaces
    readonly property color glassBarSurface: "#30252A2E"
    readonly property color islandSurface: "#C4161A1E"
    readonly property color islandSurfaceHover: "#D21B2025"
    readonly property color islandSurfaceActive: "#D21A2024"
    readonly property color popupSurface: "#EE15191D"
    readonly property color popupSurfaceRaised: "#F21B2025"
    readonly property color glassEdgeHighlight: "#526F7A80"

    // Borders
    readonly property color borderDefault: "#59616B70"
    readonly property color borderHover: "#8A7A858B"
    readonly property color borderSubtle: "#46515A60"

    // Typography
    readonly property color textPrimary: "#E6EDF1"
    readonly property color textMuted: "#AEBAC2"

    // Semantic accents
    readonly property color accentCyan: "#46C7D5"
    readonly property color accentBlue: "#607A84"
    readonly property color accentAmber: "#D69A4A"
    readonly property color accentRed: "#C85C5C"

    // Ambient telemetry
    readonly property color visualizerBar: "#849096"
    readonly property color visualizerPeak: "#C1C9CD"

    // Shared island geometry
    readonly property int islandHeight: 32
    readonly property int islandRadius: 5
    readonly property int surfaceCutSize: 5
    readonly property int islandBorderWidth: 1
    readonly property int islandPaddingHorizontal: 10
    readonly property int islandPaddingVertical: 4
    readonly property int islandGap: 8

    // Shared motion
    readonly property int animationHover: 180
    readonly property int animationState: 200
    readonly property int animationPosition: 300
    readonly property int animationVisualizer: 45
    readonly property int easingStandard: Easing.InOutSine
    readonly property int easingEntrance: Easing.OutCubic
    readonly property int easingResponsive: Easing.OutSine

}

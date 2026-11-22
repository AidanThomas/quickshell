import qs.config
import qs.components
import qs.widgets.power

import QtQuick

IslandAction {
    id: root

    readonly property bool menuOpen: powerMenu.visible

    text: "Power and session controls"
    tooltipText: text
    iconName: "session.power"
    iconSize: 18
    iconColor: root.menuOpen ? Theme.accentRed : Theme.textPrimary
    onClicked: powerMenu.toggle()

    PowerMenu {
        id: powerMenu
    }
}

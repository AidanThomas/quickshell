import QtQuick
import Quickshell.Hyprland

Item {
    property var activeWindow: {
        const ws = Hyprland.focusedWorkspace
        if (!ws) return null

        const wins = ws.toplevels.values || []
        return wins.find(w => w.activated) || null
    }

    implicitWidth: titleText.implicitWidth
    implicitHeight: titleText.implicitHeight

    Text {
        id: titleText
        anchors.centerIn: parent
        color: "white"
        elide: Text.ElideRight
        maximumLineCount: 1

        text: activeWindow?.title || "Desktop"
    }
}

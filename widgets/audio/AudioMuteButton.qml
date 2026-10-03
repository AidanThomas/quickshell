import qs.config

import QtQuick

Rectangle {
    id: root

    required property bool muted

    property string activeIcon: ""
    property string mutedIcon: "󰖁"

    signal toggled

    implicitWidth: 28
    implicitHeight: 28
    radius: Theme.islandRadius

    color: mouseArea.containsMouse ? Theme.islandSurfaceHover : "transparent"

    Text {
        font.family: Theme.iconFontFamily
        anchors.centerIn: parent
        text: root.muted ? root.mutedIcon : root.activeIcon
        color: root.muted ? Theme.accentAmber : Theme.textPrimary
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}

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
    radius: 6

    color: mouseArea.containsMouse ? Theme.surfaceHover : "transparent"

    Text {
        font.family: Theme.fontFamily
        anchors.centerIn: parent
        text: root.muted ? root.mutedIcon : root.activeIcon
        color: Theme.text
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.toggled()
    }
}

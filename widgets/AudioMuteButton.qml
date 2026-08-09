import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property bool muted

    property string activeIcon: ""
    property string mutedIcon: "󰖁"

    signal toggled()

    implicitWidth: 28
    implicitHeight: 28
    radius: 6

    color: mouseArea.containsMouse ? "#303030" : "transparent"

    Text {
        anchors.centerIn: parent
        text: root.muted ? mutedIcon : activeIcon
        color: "white"
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.toggled()
    }
}

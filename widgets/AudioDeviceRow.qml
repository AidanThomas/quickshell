import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
    id: root

    required property var node
    required property bool active

    signal selected()

    implicitHeight: visible ? 30 : 0
    Layout.fillWidth: true

    PwObjectTracker {
        objects: [node]
    }

    Rectangle {
        id: rowBackground

        anchors.fill: parent
        radius: 6

        color: {
            if (mouseArea.containsMouse)
                return "#303030"

            if (root.active)
                return "#282828"

            return "transparent"
        }

        RowLayout {
            id: row

            anchors {
                fill: parent
                leftMargin: 8
                rightMargin: 8
            }

            spacing: 8

            Rectangle {
                implicitWidth: 8
                implicitHeight: 8
                radius: 4

                color: root.active ? "white" : "transparent"
            }

            Text {
                Layout.fillWidth: true

                text: node.description.length > 0 ? node.description : node.name
                color: "white"
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            onClicked: selected()
        }
    }
}

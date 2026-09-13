import qs.config

import Quickshell
import Quickshell.Io
import QtQuick

PanelWindow {
    id: root
    visible: false
    anchors {
        top: true
        left: true
    }

    margins {
        top: 42
        left: 10
    }

    function toggle() {
        root.visible = !root.visible;
    }

    implicitWidth: 320
    implicitHeight: 240
    color: "transparent"

    IpcHandler {
        target: "powerMenu"

        function toggle(): void {
            root.toggle();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 5
        color: Theme.background
        border.width: 1
        border.color: Theme.border

        Text {
            font.family: Theme.fontFamily
            anchors.centerIn: parent
            text: "Power Menu"
            color: Theme.text
            font.pixelSize: 18
        }
    }
}

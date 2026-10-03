import qs.config
import qs.components

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

    PopupSurface {
        anchors.fill: parent
        accentColor: Theme.accentRed
        padding: 18

        Column {
            anchors.fill: parent
            spacing: 10

            Text {
                font.family: Theme.fontFamily
                text: "POWER CONTROL"
                color: Theme.textPrimary
                font.pixelSize: 14
                font.weight: Font.DemiBold
                font.letterSpacing: 1
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.borderSubtle
            }

            Text {
                width: parent.width
                text: "SYSTEM ACTIONS NOT CONFIGURED"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 10
                wrapMode: Text.Wrap
            }
        }
    }
}

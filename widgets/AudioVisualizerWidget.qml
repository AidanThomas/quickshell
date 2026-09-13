pragma ComponentBehavior: Bound

import qs.config

import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: bars.implicitWidth
    implicitHeight: 30

    property int barCount: 32

    ListModel {
        id: levels
    }

    Component.onCompleted: {
        for (let i = 0; i < root.barCount; i++) {
            levels.append({
                "level": 0
            });
        }
    }

    Process {
        id: cava
        running: true
        command: ["cava", "-p", "/home/aidant/.config/quickshell/config/cava.conf"]

        // Quickshell can start before PipeWire is ready. Cava exits when that
        // happens, so retry instead of leaving the visualizer permanently idle.
        onExited: cavaRestartTimer.restart()

        stdout: SplitParser {
            onRead: data => {
                const values = data.trim().split(";");

                for (let i = 0; i < values.length && i < levels.count; i++) {
                    const value = Number(values[i]);
                    levels.setProperty(i, "level", value / 100);
                }
            }
        }
    }

    Timer {
        id: cavaRestartTimer
        interval: 2000
        onTriggered: cava.running = true
    }

    Row {
        id: bars
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Repeater {
            model: levels

            Rectangle {
                required property real level

                width: 2
                height: 2 + level * (root.height - 2)
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.text
                radius: 1

                Behavior on height {
                    NumberAnimation {
                        duration: 35
                    }
                }
            }
        }
    }
}

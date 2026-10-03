pragma ComponentBehavior: Bound

import qs.config

import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: bars.implicitWidth
    implicitHeight: Theme.islandHeight - Theme.islandPaddingVertical * 2

    property int barCount: 32

    function barColor(level) {
        const mix = Math.max(0, Math.min(1, level)) * 0.3;
        return Qt.rgba(
            Theme.visualizerBar.r * (1 - mix) + Theme.visualizerPeak.r * mix,
            Theme.visualizerBar.g * (1 - mix) + Theme.visualizerPeak.g * mix,
            Theme.visualizerBar.b * (1 - mix) + Theme.visualizerPeak.b * mix,
            1
        );
    }

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
        spacing: 1

        Repeater {
            model: levels

            Rectangle {
                required property real level

                width: 2
                height: 2 + level * (root.height - 2)
                anchors.verticalCenter: parent.verticalCenter
                color: root.barColor(level)
                opacity: 0.4 + level * 0.55
                radius: 1

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.animationVisualizer
                        easing.type: Theme.easingResponsive
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animationVisualizer
                        easing.type: Theme.easingResponsive
                    }
                }
            }
        }
    }
}

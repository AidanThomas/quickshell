import QtQuick
import Quickshell

PanelWindow {
    id: root

    enum Corner {
        TopLeft = 0,
        TopRight = 1,
        BottomLeft = 2,
        BottomRight = 3
    }

    required property int frameThickness
    required property int corner
    required property int radius
    required property color fillColor
    property int topOffset: 0

    exclusionMode: ExclusionMode.Normal

    implicitWidth: radius
    implicitHeight: radius
    color: "transparent"

    anchors {
        top: corner === 0 || corner === 1
        left: corner === 0 || corner === 2
        right: corner === 1 || corner === 3
        bottom: corner === 2 || corner === 3
    }

    margins {
        top: corner === 0 || corner === 1 ? topOffset : 0
        left: corner === 0 || corner === 2 ? frameThickness : 0
        right: corner === 1 || corner === 3 ? frameThickness : 0
        bottom: corner === 2 || corner === 3 ? frameThickness : 0
    }

    Canvas {
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            const ctx = getContext("2d");
            const r = root.radius;

            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            ctx.fillStyle = root.fillColor;
            ctx.beginPath();

            switch (root.corner) {
            case 0: // TopLeft
                ctx.moveTo(0, 0);
                ctx.lineTo(r, 0);
                ctx.quadraticCurveTo(0, 0, 0, r);
                break;
            case 1: // TopRight
                ctx.moveTo(0, 0);
                ctx.lineTo(r, 0);
                ctx.lineTo(r, r);
                ctx.quadraticCurveTo(r, 0, 0, 0);
                break;
            case 2: // BottomLeft
                ctx.moveTo(0, 0);
                ctx.lineTo(0, r);
                ctx.lineTo(r, r);
                ctx.quadraticCurveTo(0, r, 0, 0);
                break;
            case 3: // BottomRight
                ctx.moveTo(r, 0);
                ctx.lineTo(r, r);
                ctx.lineTo(0, r);
                ctx.quadraticCurveTo(r, r, r, 0);
                break;
            }

            ctx.closePath();
            ctx.fill();
        }
    }
}

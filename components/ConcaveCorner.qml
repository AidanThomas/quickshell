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
            ctx.fillRect(0, 0, r, r);

            ctx.globalCompositeOperation = "destination-out";
            ctx.beginPath();

            switch (root.corner) {
            case 0: // TopLeft
                ctx.moveTo(r, r);
                ctx.lineTo(0, r);
                ctx.arc(r, r, r, Math.PI, 1.5 * Math.PI, false);
                break;
            case 1: // TopRight
                ctx.moveTo(0, r);
                ctx.lineTo(0, 0);
                ctx.arc(0, r, r, -Math.PI / 2, 0, false);
                break;
            case 2: // BottomLeft
                ctx.moveTo(r, 0);
                ctx.lineTo(0, 0);
                ctx.arc(r, 0, r, Math.PI, Math.PI / 2, true);
                break;
            case 3: // BottomRight
                ctx.moveTo(0, 0);
                ctx.lineTo(r, 0);
                ctx.arc(0, 0, r, 0, Math.PI / 2, false);
                break;
            }

            ctx.closePath();
            ctx.fill();
            ctx.globalCompositeOperation = "source-over";
        }
    }
}

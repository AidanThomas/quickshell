import QtQuick

Canvas {
    id: root

    enum Corner {
        TopLeft = 0,
        TopRight = 1,
        BottomLeft = 2,
        BottomRight = 3
    }

    required property int corner
    required property int radius
    required property color fillColor

    implicitWidth: radius
    implicitHeight: radius
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

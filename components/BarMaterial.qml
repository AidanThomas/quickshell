import QtQuick

Canvas {
    id: root

    required property Item leftTarget
    required property Item centreTarget
    required property Item rightTarget
    required property color fillColor

    property int connectorHeight: 6
    property int shoulderRadius: 18
    property int bottomRadius: 14
    property int barHeight: parent?.height ?? 0

    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
    }
    height: barHeight + shoulderRadius
    antialiasing: true

    function addRegion(ctx, region, curveLeft, curveRight, extendLeftEdge, extendRightEdge) {
        if (region.width <= 0)
            return;

        const x = region.x;
        const width = region.width;
        const right = x + width;
        const bottom = root.barHeight;
        const shoulder = Math.min(root.shoulderRadius, width / 2);
        const bottomLeft = extendLeftEdge ? root.shoulderRadius : Math.min(root.bottomRadius, width / 2);
        const bottomRight = extendRightEdge ? root.shoulderRadius : Math.min(root.bottomRadius, width / 2);
        const leftTop = curveLeft ? x - shoulder : x;
        const rightTop = curveRight ? right + shoulder : right;

        ctx.moveTo(leftTop, root.connectorHeight);
        ctx.lineTo(rightTop, root.connectorHeight);

        if (curveRight)
            ctx.quadraticCurveTo(right, root.connectorHeight, right, root.connectorHeight + shoulder);
        else
            ctx.lineTo(right, root.connectorHeight);

        if (extendRightEdge) {
            ctx.lineTo(right, bottom + bottomRight);
            ctx.quadraticCurveTo(right, bottom, right - bottomRight, bottom);
        } else {
            ctx.lineTo(right, bottom - bottomRight);
            ctx.quadraticCurveTo(right, bottom, right - bottomRight, bottom);
        }

        ctx.lineTo(x + bottomLeft, bottom);
        if (extendLeftEdge) {
            ctx.quadraticCurveTo(x, bottom, x, bottom + bottomLeft);
            ctx.lineTo(x, root.connectorHeight);
        } else {
            ctx.quadraticCurveTo(x, bottom, x, bottom - bottomLeft);
            ctx.lineTo(x, root.connectorHeight + (curveLeft ? shoulder : 0));
            if (curveLeft)
                ctx.quadraticCurveTo(x, root.connectorHeight, leftTop, root.connectorHeight);
        }

        ctx.closePath();
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.clearRect(0, 0, width, height);
        ctx.fillStyle = root.fillColor;
        ctx.beginPath();

        // The connector and all occupied lobes are subpaths of one fill. Their
        // union is rasterised once, avoiding doubled translucent material where
        // independently drawn glass pieces would otherwise meet.
        ctx.rect(0, 0, width, root.connectorHeight);
        root.addRegion(ctx, root.leftTarget, false, true, true, false);
        root.addRegion(ctx, root.centreTarget, true, true, false, false);
        root.addRegion(ctx, root.rightTarget, true, false, false, true);
        ctx.fill();
    }

    Connections {
        target: root.leftTarget
        function onXChanged() { root.requestPaint(); }
        function onWidthChanged() { root.requestPaint(); }
    }

    Connections {
        target: root.centreTarget
        function onXChanged() { root.requestPaint(); }
        function onWidthChanged() { root.requestPaint(); }
    }

    Connections {
        target: root.rightTarget
        function onXChanged() { root.requestPaint(); }
        function onWidthChanged() { root.requestPaint(); }
    }

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onFillColorChanged: requestPaint()
}

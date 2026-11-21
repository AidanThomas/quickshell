import QtQuick

Canvas {
    id: root

    required property Item leftTarget
    required property Item centreTarget
    required property Item rightTarget
    required property color fillColor

    property rect disclosureRect: Qt.rect(0, 0, 0, 0)
    property rect disclosureOriginRect: Qt.rect(0, 0, 0, 0)
    property real disclosureProgress: 0
    property real disclosureRadius: 22

    property int connectorHeight: 6
    property int shoulderRadius: 18
    property int bottomRadius: 14
    property int barHeight: parent?.height ?? 0

    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
    }
    height: Math.max(
        barHeight + shoulderRadius,
        disclosureRect.y + disclosureRect.height + disclosureRadius
    )
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

    function addRoundedRect(ctx, x, y, width, height, radius) {
        if (width <= 0 || height <= 0)
            return;

        const r = Math.min(radius, width / 2, height / 2);
        ctx.moveTo(x + r, y);
        ctx.lineTo(x + width - r, y);
        ctx.quadraticCurveTo(x + width, y, x + width, y + r);
        ctx.lineTo(x + width, y + height - r);
        ctx.quadraticCurveTo(x + width, y + height, x + width - r, y + height);
        ctx.lineTo(x + r, y + height);
        ctx.quadraticCurveTo(x, y + height, x, y + height - r);
        ctx.lineTo(x, y + r);
        ctx.quadraticCurveTo(x, y, x + r, y);
        ctx.closePath();
    }

    function addDisclosure(ctx) {
        const progress = Math.max(0, Math.min(1, root.disclosureProgress));
        const surface = root.disclosureRect;
        if (progress <= 0 || surface.width <= 0 || surface.height <= 0)
            return;

        const revealedHeight = surface.height * progress;
        root.addRoundedRect(
            ctx,
            surface.x,
            surface.y,
            surface.width,
            revealedHeight,
            root.disclosureRadius
        );

        const origin = root.disclosureOriginRect;
        const originCenter = origin.x + origin.width / 2;
        let region = root.rightTarget;
        if (originCenter >= root.leftTarget.x && originCenter <= root.leftTarget.x + root.leftTarget.width)
            region = root.leftTarget;
        else if (root.centreTarget.width > 0 && originCenter >= root.centreTarget.x && originCenter <= root.centreTarget.x + root.centreTarget.width)
            region = root.centreTarget;

        const regionLeft = region.x;
        const regionRight = region.x + region.width;
        const surfaceLeft = surface.x;
        const surfaceRight = surface.x + surface.width;
        const bridgeTop = root.barHeight - 1;
        // Centre a deliberately narrow pillar beneath the disclosure origin.
        const neckWidth = Math.min(origin.width * 0.20, region.width);
        const unclampedLeftNeck = originCenter - neckWidth / 2;
        const leftNeck = Math.max(
            regionLeft,
            Math.min(unclampedLeftNeck, regionRight - neckWidth)
        );
        const rightNeck = leftNeck + neckWidth;
        const surfaceTop = surface.y;
        const joinRadius = Math.min(
            root.bottomRadius,
            revealedHeight / 2,
            Math.max(0, (surfaceTop - bridgeTop) / 2)
        );
        // Use one radius on both sides so clamping can never leave the pillar
        // with mismatched shoulders.
        const sideJoinRadius = Math.max(0, Math.min(
            joinRadius,
            leftNeck - regionLeft,
            leftNeck - surfaceLeft,
            regionRight - rightNeck,
            surfaceRight - rightNeck
        ));
        const topLeftShoulder = leftNeck - sideJoinRadius;
        const topRightShoulder = rightNeck + sideJoinRadius;
        const bottomLeftShoulder = leftNeck - sideJoinRadius;
        const bottomRightShoulder = rightNeck + sideJoinRadius;

        ctx.moveTo(topLeftShoulder, bridgeTop);
        // Match the clockwise winding of the bar and popup subpaths. Reversing
        // this path makes its overlaps union under Canvas's non-zero fill rule
        // instead of punching transparent holes through the shared material.
        ctx.lineTo(topRightShoulder, bridgeTop);
        ctx.quadraticCurveTo(rightNeck, bridgeTop, rightNeck, bridgeTop + sideJoinRadius);
        ctx.lineTo(rightNeck, surfaceTop - sideJoinRadius);
        ctx.quadraticCurveTo(rightNeck, surfaceTop, bottomRightShoulder, surfaceTop);
        ctx.lineTo(bottomRightShoulder, surfaceTop + sideJoinRadius);
        ctx.lineTo(bottomLeftShoulder, surfaceTop + sideJoinRadius);
        ctx.lineTo(bottomLeftShoulder, surfaceTop);
        ctx.quadraticCurveTo(leftNeck, surfaceTop, leftNeck, surfaceTop - sideJoinRadius);
        ctx.lineTo(leftNeck, bridgeTop + sideJoinRadius);
        ctx.quadraticCurveTo(leftNeck, bridgeTop, topLeftShoulder, bridgeTop);
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
        root.addDisclosure(ctx);
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
    onDisclosureRectChanged: requestPaint()
    onDisclosureOriginRectChanged: requestPaint()
    onDisclosureProgressChanged: requestPaint()
}

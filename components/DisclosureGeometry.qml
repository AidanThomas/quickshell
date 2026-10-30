import QtQuick

QtObject {
    id: root

    enum Edge {
        Top,
        Right,
        Bottom,
        Left
    }

    property Item origin: null
    property Item targetItem: null
    property bool active: false

    // An empty rectangle falls back to the geometry of the origin's screen.
    property rect availableGeometry: Qt.rect(0, 0, 0, 0)
    property real requestedSurfaceWidth: targetItem?.width ?? 0
    property real requestedSurfaceHeight: targetItem?.height ?? 0
    property int originEdge: DisclosureGeometry.Bottom
    property real surfaceGap: 4
    property real screenMargin: 8
    property real connectorWidth: 28
    property real connectorThickness: 4
    property real connectorEdgeMargin: 16
    property int activeRefreshInterval: 16

    readonly property bool valid: internal.valid
    readonly property rect originGlobalRect: internal.originGlobalRect
    readonly property rect originTargetRect: internal.originTargetRect
    readonly property point originAnchorGlobal: internal.originAnchorGlobal
    readonly property point originAnchorTarget: internal.originAnchorTarget
    readonly property rect desiredSurfaceRect: internal.desiredSurfaceRect
    readonly property rect surfaceRect: internal.surfaceRect
    readonly property point surfaceOffset: Qt.point(surfaceRect.x - desiredSurfaceRect.x, surfaceRect.y - desiredSurfaceRect.y)
    readonly property bool placementAdjusted: !root.fuzzyEqual(surfaceOffset.x, 0) || !root.fuzzyEqual(surfaceOffset.y, 0)
    readonly property bool surfaceConstrained: !root.fuzzyEqual(surfaceRect.width, desiredSurfaceRect.width) || !root.fuzzyEqual(surfaceRect.height, desiredSurfaceRect.height)
    readonly property real connectorCenter: internal.connectorCenter
    readonly property rect connectorRect: internal.connectorRect

    signal geometryUpdated

    function refresh(): void {
        if (!root.origin || !root.origin.visible || root.origin.width <= 0 || root.origin.height <= 0) {
            root.invalidate();
            return;
        }

        const originTopLeft = root.origin.mapToGlobal(Qt.point(0, 0));
        const originBottomRight = root.origin.mapToGlobal(Qt.point(root.origin.width, root.origin.height));
        if (!root.finitePoint(originTopLeft) || !root.finitePoint(originBottomRight)) {
            root.invalidate();
            return;
        }

        const globalOrigin = root.normalizedRect(originTopLeft, originBottomRight);
        const bounds = root.resolvedAvailableGeometry();
        const requestedWidth = Math.max(0, root.requestedSurfaceWidth);
        const requestedHeight = Math.max(0, root.requestedSurfaceHeight);
        if (bounds.width <= 0 || bounds.height <= 0 || requestedWidth <= 0 || requestedHeight <= 0) {
            root.invalidate();
            return;
        }

        const anchor = root.anchorForRect(globalOrigin, root.originEdge);
        const desired = root.surfaceRectForAnchor(anchor, requestedWidth, requestedHeight, root.originEdge);
        const fitted = root.fitRect(desired, bounds, root.screenMargin);

        let targetOrigin = Qt.point(anchor.x - fitted.x, anchor.y - fitted.y);
        let targetRect = Qt.rect(globalOrigin.x - fitted.x, globalOrigin.y - fitted.y, globalOrigin.width, globalOrigin.height);

        if (root.targetItem && root.targetItem.window) {
            const mappedTopLeft = root.targetItem.mapFromGlobal(Qt.point(globalOrigin.x, globalOrigin.y));
            const mappedBottomRight = root.targetItem.mapFromGlobal(Qt.point(globalOrigin.x + globalOrigin.width, globalOrigin.y + globalOrigin.height));
            const mappedAnchor = root.targetItem.mapFromGlobal(anchor);
            if (root.finitePoint(mappedTopLeft) && root.finitePoint(mappedBottomRight) && root.finitePoint(mappedAnchor)) {
                targetRect = root.normalizedRect(mappedTopLeft, mappedBottomRight);
                targetOrigin = mappedAnchor;
            }
        }

        const connector = root.connectorForSurface(anchor, fitted, root.originEdge, root.connectorWidth, root.connectorThickness, root.connectorEdgeMargin);

        const changed = !internal.valid || !root.rectEqual(internal.originGlobalRect, globalOrigin) || !root.rectEqual(internal.originTargetRect, targetRect) || !root.pointEqual(internal.originAnchorGlobal, anchor) || !root.pointEqual(internal.originAnchorTarget, targetOrigin) || !root.rectEqual(internal.desiredSurfaceRect, desired) || !root.rectEqual(internal.surfaceRect, fitted) || !root.fuzzyEqual(internal.connectorCenter, connector.center) || !root.rectEqual(internal.connectorRect, connector.rect);

        internal.originGlobalRect = globalOrigin;
        internal.originTargetRect = targetRect;
        internal.originAnchorGlobal = anchor;
        internal.originAnchorTarget = targetOrigin;
        internal.desiredSurfaceRect = desired;
        internal.surfaceRect = fitted;
        internal.connectorCenter = connector.center;
        internal.connectorRect = connector.rect;
        internal.valid = true;
        if (changed)
            root.geometryUpdated();
    }

    function invalidate(): void {
        if (!internal.valid)
            return;

        internal.valid = false;
        root.geometryUpdated();
    }

    function resolvedAvailableGeometry(): rect {
        if (root.availableGeometry.width > 0 && root.availableGeometry.height > 0)
            return root.availableGeometry;

        const screen = root.origin?.window?.screen ?? null;
        if (!screen)
            return Qt.rect(0, 0, 0, 0);

        const geometry = screen.availableGeometry ?? screen.geometry;
        return Qt.rect(geometry.x, geometry.y, geometry.width, geometry.height);
    }

    function anchorForRect(rectangle: rect, edge: int): point {
        if (edge === DisclosureGeometry.Top)
            return Qt.point(rectangle.x + rectangle.width / 2, rectangle.y);
        if (edge === DisclosureGeometry.Right)
            return Qt.point(rectangle.x + rectangle.width, rectangle.y + rectangle.height / 2);
        if (edge === DisclosureGeometry.Left)
            return Qt.point(rectangle.x, rectangle.y + rectangle.height / 2);

        return Qt.point(rectangle.x + rectangle.width / 2, rectangle.y + rectangle.height);
    }

    function surfaceRectForAnchor(anchor: point, width: real, height: real, edge: int): rect {
        if (edge === DisclosureGeometry.Top) {
            return Qt.rect(anchor.x - width / 2, anchor.y - root.surfaceGap - height, width, height);
        }
        if (edge === DisclosureGeometry.Right) {
            return Qt.rect(anchor.x + root.surfaceGap, anchor.y - height / 2, width, height);
        }
        if (edge === DisclosureGeometry.Left) {
            return Qt.rect(anchor.x - root.surfaceGap - width, anchor.y - height / 2, width, height);
        }

        return Qt.rect(anchor.x - width / 2, anchor.y + root.surfaceGap, width, height);
    }

    function fitRect(rectangle: rect, bounds: rect, margin: real): rect {
        const safeMargin = Math.max(0, margin);
        const left = bounds.x + safeMargin;
        const top = bounds.y + safeMargin;
        const availableWidth = Math.max(0, bounds.width - safeMargin * 2);
        const availableHeight = Math.max(0, bounds.height - safeMargin * 2);
        const width = Math.min(rectangle.width, availableWidth);
        const height = Math.min(rectangle.height, availableHeight);
        const maximumX = left + availableWidth - width;
        const maximumY = top + availableHeight - height;

        return Qt.rect(root.clamp(rectangle.x, left, maximumX), root.clamp(rectangle.y, top, maximumY), width, height);
    }

    function connectorForSurface(anchor: point, surface: rect, edge: int, requestedWidth: real, thickness: real, edgeMargin: real): var {
        const width = Math.max(0, requestedWidth);
        const depth = Math.max(0, thickness);
        const margin = Math.max(0, edgeMargin);

        if (edge === DisclosureGeometry.Top || edge === DisclosureGeometry.Bottom) {
            const effectiveMargin = Math.min(margin, surface.width / 2);
            const maximumWidth = Math.max(0, surface.width - effectiveMargin * 2);
            const fittedWidth = Math.min(width, maximumWidth);
            const minimumCenter = effectiveMargin + fittedWidth / 2;
            const maximumCenter = surface.width - effectiveMargin - fittedWidth / 2;
            const center = root.clamp(anchor.x - surface.x, minimumCenter, maximumCenter);
            const y = edge === DisclosureGeometry.Bottom ? -depth : surface.height;
            return {
                center: center,
                rect: Qt.rect(center - fittedWidth / 2, y, fittedWidth, depth)
            };
        }

        const effectiveMargin = Math.min(margin, surface.height / 2);
        const maximumHeight = Math.max(0, surface.height - effectiveMargin * 2);
        const fittedHeight = Math.min(width, maximumHeight);
        const minimumCenter = effectiveMargin + fittedHeight / 2;
        const maximumCenter = surface.height - effectiveMargin - fittedHeight / 2;
        const center = root.clamp(anchor.y - surface.y, minimumCenter, maximumCenter);
        const x = edge === DisclosureGeometry.Right ? -depth : surface.width;
        return {
            center: center,
            rect: Qt.rect(x, center - fittedHeight / 2, depth, fittedHeight)
        };
    }

    function normalizedRect(first: point, second: point): rect {
        const left = Math.min(first.x, second.x);
        const top = Math.min(first.y, second.y);
        return Qt.rect(left, top, Math.abs(second.x - first.x), Math.abs(second.y - first.y));
    }

    function clamp(value: real, minimum: real, maximum: real): real {
        if (maximum < minimum)
            return minimum;
        return Math.max(minimum, Math.min(maximum, value));
    }

    function finitePoint(value: point): bool {
        return Number.isFinite(value.x) && Number.isFinite(value.y);
    }

    function fuzzyEqual(first: real, second: real): bool {
        return Math.abs(first - second) < 0.01;
    }

    function pointEqual(first: point, second: point): bool {
        return root.fuzzyEqual(first.x, second.x) && root.fuzzyEqual(first.y, second.y);
    }

    function rectEqual(first: rect, second: rect): bool {
        return root.fuzzyEqual(first.x, second.x) && root.fuzzyEqual(first.y, second.y) && root.fuzzyEqual(first.width, second.width) && root.fuzzyEqual(first.height, second.height);
    }

    onOriginChanged: refresh()
    onTargetItemChanged: refresh()
    onAvailableGeometryChanged: refresh()
    onRequestedSurfaceWidthChanged: refresh()
    onRequestedSurfaceHeightChanged: refresh()
    onOriginEdgeChanged: refresh()
    onSurfaceGapChanged: refresh()
    onScreenMarginChanged: refresh()
    onConnectorWidthChanged: refresh()
    onConnectorThicknessChanged: refresh()
    onConnectorEdgeMarginChanged: refresh()

    property Connections originConnections: Connections {
        target: root.origin
        enabled: target !== null
        ignoreUnknownSignals: true

        function onXChanged(): void {
            root.refresh();
        }
        function onYChanged(): void {
            root.refresh();
        }
        function onWidthChanged(): void {
            root.refresh();
        }
        function onHeightChanged(): void {
            root.refresh();
        }
        function onVisibleChanged(): void {
            root.refresh();
        }
        function onWindowChanged(): void {
            root.refresh();
        }
        function onDestroyed(): void {
            root.invalidate();
        }
    }

    property Connections originWindowConnections: Connections {
        target: root.origin?.window ?? null
        enabled: target !== null
        ignoreUnknownSignals: true

        function onXChanged(): void {
            root.refresh();
        }
        function onYChanged(): void {
            root.refresh();
        }
        function onWidthChanged(): void {
            root.refresh();
        }
        function onHeightChanged(): void {
            root.refresh();
        }
        function onScreenChanged(): void {
            root.refresh();
        }
    }

    property Connections targetConnections: Connections {
        target: root.targetItem
        enabled: target !== null
        ignoreUnknownSignals: true

        function onXChanged(): void {
            root.refresh();
        }
        function onYChanged(): void {
            root.refresh();
        }
        function onWidthChanged(): void {
            root.refresh();
        }
        function onHeightChanged(): void {
            root.refresh();
        }
        function onWindowChanged(): void {
            root.refresh();
        }
        function onDestroyed(): void {
            root.refresh();
        }
    }

    property Connections targetWindowConnections: Connections {
        target: root.targetItem?.window ?? null
        enabled: target !== null
        ignoreUnknownSignals: true

        function onXChanged(): void {
            root.refresh();
        }
        function onYChanged(): void {
            root.refresh();
        }
        function onWidthChanged(): void {
            root.refresh();
        }
        function onHeightChanged(): void {
            root.refresh();
        }
        function onScreenChanged(): void {
            root.refresh();
        }
    }

    // Ancestor layout and compositor-window movement are not guaranteed to emit
    // a signal on the origin item itself. Refreshing while the disclosure is
    // active keeps cross-window geometry correct without polling at rest.
    property Timer activeRefresh: Timer {
        interval: Math.max(1, root.activeRefreshInterval)
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }

    property QtObject internal: QtObject {
        property bool valid: false
        property rect originGlobalRect: Qt.rect(0, 0, 0, 0)
        property rect originTargetRect: Qt.rect(0, 0, 0, 0)
        property point originAnchorGlobal: Qt.point(0, 0)
        property point originAnchorTarget: Qt.point(0, 0)
        property rect desiredSurfaceRect: Qt.rect(0, 0, 0, 0)
        property rect surfaceRect: Qt.rect(0, 0, 0, 0)
        property real connectorCenter: 0
        property rect connectorRect: Qt.rect(0, 0, 0, 0)
    }

    Component.onCompleted: refresh()
}

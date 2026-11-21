import qs.config

import QtQuick
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root

    default property alias content: contentContainer.data

    required property Item origin

    property string scopeId: DisclosureCoordinator.defaultScope
    property bool exclusiveInScope: true
    property bool originAvailable: true
    property bool focusOnOpen: true
    property bool clickAwayEnabled: true
    property bool reducedMotion: MotionPreferences.reducedMotion
    property bool integratedCanopy: true
    property int originEdge: DisclosureGeometry.Bottom
    property real surfaceGap: 4
    // Integrated glass extends beyond the logical popup surface, so reserve
    // that backing as well as the visible output-edge gap during fitting.
    property real screenMargin: Theme.screenEdgeGap
        + (canopyPresentationActive ? Theme.canopyBackingMargin : 0)

    readonly property alias lifecycle: disclosureLifecycle
    readonly property alias geometry: disclosureGeometry
    readonly property real revealProgress: disclosureLifecycle.transitionProgress
    readonly property bool effectiveOpen: disclosureLifecycle.effectiveOpen
    readonly property bool interactionEnabled: disclosureLifecycle.interactive
    readonly property bool canopyPresentationActive: integratedCanopy
        && CanopyDisclosure.hostAvailable
        && originEdge === DisclosureGeometry.Bottom
    readonly property rect canopySurfaceRect: disclosureGeometry.surfaceRect
    readonly property rect canopyOriginRect: disclosureGeometry.originGlobalRect
    readonly property real canopyProgress: revealProgress
    readonly property int canopyOriginEdge: originEdge

    property Item initialFocusTarget: contentContainer

    function requestOpen(inputSource = DisclosureLifecycle.ProgrammaticInput): bool {
        return disclosureLifecycle.requestOpen(inputSource);
    }

    function requestClose(reason = DisclosureLifecycle.Programmatic, inputSource = DisclosureLifecycle.ProgrammaticInput, restoreFocus = false): bool {
        return disclosureLifecycle.requestClose(reason, inputSource, restoreFocus);
    }

    function toggle(inputSource = DisclosureLifecycle.Pointer): bool {
        return disclosureLifecycle.toggle(inputSource);
    }

    function anchorEdgesFor(edge: int): int {
        if (edge === DisclosureGeometry.Top)
            return Edges.Top;
        if (edge === DisclosureGeometry.Right)
            return Edges.Right;
        if (edge === DisclosureGeometry.Left)
            return Edges.Left;
        return Edges.Bottom;
    }

    function focusReasonFor(inputSource: int): int {
        if (inputSource === DisclosureLifecycle.Keyboard || inputSource === DisclosureLifecycle.Shortcut || inputSource === DisclosureLifecycle.Ipc)
            return Qt.TabFocusReason;

        return Qt.MouseFocusReason;
    }

    function fittedAnchorRect(): rect {
        if (!root.geometry.valid || !root.origin)
            return Qt.rect(0, 0, root.origin?.width ?? 1, root.origin?.height ?? 1);

        const originRect = root.geometry.originGlobalRect;
        const surface = root.geometry.surfaceRect;
        if (root.originEdge === DisclosureGeometry.Top || root.originEdge === DisclosureGeometry.Bottom) {
            const localCenter = surface.x + surface.width / 2 - originRect.x;
            return Qt.rect(localCenter - 0.5, 0, 1, root.origin.height);
        }

        const localCenter = surface.y + surface.height / 2 - originRect.y;
        return Qt.rect(0, localCenter - 0.5, root.origin.width, 1);
    }

    visible: adapterState.mapped
    color: "transparent"

    // Native grabFocus unmaps PopupWindow immediately on outside activation.
    // HyprlandFocusGrab lets the shared lifecycle keep it mapped while closing.
    grabFocus: false

    anchor {
        item: root.origin
        rect: root.fittedAnchorRect()
        edges: root.anchorEdgesFor(root.originEdge)
        gravity: root.anchorEdgesFor(root.originEdge)
        adjustment: PopupAdjustment.SlideX | PopupAdjustment.SlideY

        margins {
            // PopupAnchor margins are removed from the anchor rectangle. Expand
            // the attachment edge outwards so surfaceGap offsets the popup in
            // its reveal direction instead of shrinking the opposite edge.
            top: root.originEdge === DisclosureGeometry.Top ? -Math.round(root.surfaceGap) : 0
            right: root.originEdge === DisclosureGeometry.Right ? -Math.round(root.surfaceGap) : 0
            bottom: root.originEdge === DisclosureGeometry.Bottom ? -Math.round(root.surfaceGap) : 0
            left: root.originEdge === DisclosureGeometry.Left ? -Math.round(root.surfaceGap) : 0
        }
    }

    mask: Region {
        item: disclosureLifecycle.interactive ? contentContainer : null
    }

    Item {
        id: contentContainer

        anchors.fill: parent
        enabled: disclosureLifecycle.interactive
        visible: disclosureLifecycle.effectiveOpen
    }

    DisclosureLifecycle {
        id: disclosureLifecycle

        origin: root.origin
        focusTarget: root.initialFocusTarget
        scopeId: root.scopeId
        exclusiveInScope: root.exclusiveInScope
        originAvailable: root.originAvailable
        focusOnOpen: root.focusOnOpen
        reducedMotion: root.reducedMotion

        onMappingRequested: {
            adapterState.mapped = true;
            Qt.callLater(() => {
                if (!disclosureLifecycle.requestedOpen || !adapterState.mapped)
                    return;

                root.anchor.updateAnchor();
                disclosureGeometry.refresh();
                disclosureLifecycle.notifySurfaceReady();
            });
        }

        onUnmappingRequested: adapterState.mapped = false

        onFocusEntryRequested: (target, inputSource) => {
            const destination = target ?? contentContainer;
            if (destination)
                destination.forceActiveFocus(root.focusReasonFor(inputSource));
        }

        onFocusReleaseRequested: contentContainer.focus = false

        onFocusRestorationRequested: (origin, reason) => {
            if (origin)
                origin.forceActiveFocus(Qt.TabFocusReason);
        }
    }

    DisclosureGeometry {
        id: disclosureGeometry

        origin: root.origin
        targetItem: contentContainer
        active: disclosureLifecycle.effectiveOpen
        requestedSurfaceWidth: root.implicitWidth
        requestedSurfaceHeight: root.implicitHeight
        originEdge: root.originEdge
        surfaceGap: root.surfaceGap
        screenMargin: root.screenMargin

        onGeometryUpdated: {
            if (disclosureLifecycle.effectiveOpen)
                root.anchor.updateAnchor();
        }
    }

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: root.clickAwayEnabled && disclosureLifecycle.interactive

        onCleared: {
            if (disclosureLifecycle.requestedOpen) {
                disclosureLifecycle.requestClose(DisclosureLifecycle.FocusLoss, DisclosureLifecycle.Pointer);
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: disclosureLifecycle.interactive
        context: Qt.WindowShortcut

        onActivated: {
            disclosureLifecycle.requestClose(DisclosureLifecycle.Escape, DisclosureLifecycle.Keyboard);
        }
    }

    property QtObject adapterState: QtObject {
        property bool mapped: false
    }

    onVisibleChanged: {
        if (adapterState.mapped && !visible && disclosureLifecycle.requestedOpen) {
            disclosureLifecycle.requestClose(DisclosureLifecycle.FocusLoss, DisclosureLifecycle.ProgrammaticInput);
        }
    }

    onEffectiveOpenChanged: {
        if (effectiveOpen)
            CanopyDisclosure.claim(root);
        else
            CanopyDisclosure.release(root);
    }

    Component.onDestruction: CanopyDisclosure.release(root)
}

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root

    default property alias content: contentContainer.data

    required property Item origin

    property string scopeId: DisclosureCoordinator.defaultScope
    property bool exclusiveInScope: true
    property bool originAvailable: true
    property bool focusOnOpen: true
    property bool clickAwayEnabled: true
    property bool reducedMotion: false
    property string layerNamespace: "quickshell:disclosure"
    property int originEdge: DisclosureGeometry.Right
    property real surfaceGap: 0
    property real screenMargin: 8

    // Fullscreen layer surfaces should point this at their actual interactive
    // disclosure. Everything outside this item remains click-through.
    property Item inputTarget: contentContainer
    property Item initialFocusTarget: contentContainer

    readonly property alias lifecycle: disclosureLifecycle
    readonly property alias geometry: disclosureGeometry
    readonly property real revealProgress: disclosureLifecycle.transitionProgress
    readonly property bool effectiveOpen: disclosureLifecycle.effectiveOpen
    readonly property bool interactionEnabled: disclosureLifecycle.interactive

    function requestOpen(inputSource = DisclosureLifecycle.ProgrammaticInput): bool {
        return disclosureLifecycle.requestOpen(inputSource);
    }

    function requestClose(reason = DisclosureLifecycle.Programmatic, inputSource = DisclosureLifecycle.ProgrammaticInput, restoreFocus = false): bool {
        return disclosureLifecycle.requestClose(reason, inputSource, restoreFocus);
    }

    function toggle(inputSource = DisclosureLifecycle.Pointer): bool {
        return disclosureLifecycle.toggle(inputSource);
    }

    function focusReasonFor(inputSource: int): int {
        if (inputSource === DisclosureLifecycle.Keyboard || inputSource === DisclosureLifecycle.Shortcut || inputSource === DisclosureLifecycle.Ipc)
            return Qt.TabFocusReason;

        return Qt.MouseFocusReason;
    }

    visible: adapterState.mapped
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: disclosureLifecycle.interactive && root.focusOnOpen

    WlrLayershell.namespace: root.layerNamespace

    // Remove the native input region before the closing presentation runs so
    // a transparent or off-screen layer can never consume application clicks.
    mask: Region {
        item: disclosureLifecycle.interactive ? root.inputTarget : null
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
        targetItem: root.inputTarget
        active: disclosureLifecycle.effectiveOpen
        requestedSurfaceWidth: root.inputTarget?.width ?? root.implicitWidth
        requestedSurfaceHeight: root.inputTarget?.height ?? root.implicitHeight
        originEdge: root.originEdge
        surfaceGap: root.surfaceGap
        screenMargin: root.screenMargin
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
}

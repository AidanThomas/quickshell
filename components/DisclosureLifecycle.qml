import qs.config

import QtQuick

QtObject {
    id: root

    enum State {
        Closed,
        Opening,
        Open,
        Closing
    }

    enum DismissalReason {
        NoDismissal,
        OriginToggle,
        Escape,
        OutsideActivation,
        FocusLoss,
        Replacement,
        OriginUnavailable,
        Programmatic
    }

    enum InputSource {
        Pointer,
        Keyboard,
        Shortcut,
        Ipc,
        ProgrammaticInput
    }

    property Item origin: null
    property Item focusTarget: null
    property string scopeId: DisclosureCoordinator.defaultScope
    property bool exclusiveInScope: true
    property bool originAvailable: true
    property bool focusOnOpen: true
    property bool reducedMotion: false
    property int transitionDuration: Theme.animationState
    property int transitionEasing: Theme.easingStandard

    readonly property bool requestedOpen: internal.requestedOpen
    readonly property int lifecycleState: internal.lifecycleState
    readonly property real transitionProgress: internal.transitionProgress
    readonly property bool effectiveOpen: lifecycleState !== DisclosureLifecycle.Closed
    readonly property bool interactive: requestedOpen && internal.surfaceReady && (lifecycleState === DisclosureLifecycle.Opening || lifecycleState === DisclosureLifecycle.Open)
    readonly property bool originUsable: origin !== null && origin.visible && origin.enabled && originAvailable
    readonly property int lastDismissalReason: internal.lastDismissalReason
    readonly property int openInputSource: internal.openInputSource

    signal mappingRequested
    signal unmappingRequested
    signal focusEntryRequested(Item target, int inputSource)
    signal focusReleaseRequested(int reason)
    signal focusRestorationRequested(Item origin, int reason)
    signal openRejected
    signal opened
    signal closed(int reason)

    function requestOpen(inputSource = DisclosureLifecycle.ProgrammaticInput): bool {
        if (!root.originUsable) {
            root.openRejected();
            return false;
        }

        if (internal.requestedOpen)
            return false;

        internal.requestedOpen = true;
        internal.openInputSource = inputSource;
        internal.lastDismissalReason = DisclosureLifecycle.NoDismissal;
        internal.restoreFocusOnClose = false;
        DisclosureCoordinator.activate(root);

        if (internal.lifecycleState === DisclosureLifecycle.Closed) {
            internal.activeOrigin = root.origin;
            internal.focusEntrySent = false;
            internal.surfaceReady = false;
            root.mappingRequested();
        }

        internal.lifecycleState = DisclosureLifecycle.Opening;
        root.requestFocusEntryIfReady();
        root.startTransition(1);
        return true;
    }

    function requestClose(reason = DisclosureLifecycle.Programmatic, inputSource = DisclosureLifecycle.ProgrammaticInput, restoreFocus = false): bool {
        if (internal.lifecycleState === DisclosureLifecycle.Closed)
            return false;

        internal.requestedOpen = false;
        internal.lastDismissalReason = reason;
        internal.restoreFocusOnClose = root.shouldRestoreFocus(reason, inputSource, restoreFocus);

        // A later close request may refine the reason while a close is already in
        // flight. In particular, replacement must cancel stale focus restoration.
        if (internal.lifecycleState === DisclosureLifecycle.Closing)
            return true;

        root.focusReleaseRequested(reason);
        internal.lifecycleState = DisclosureLifecycle.Closing;
        root.startTransition(0);
        return true;
    }

    function toggle(inputSource = DisclosureLifecycle.Pointer): bool {
        if (internal.requestedOpen)
            return root.requestClose(DisclosureLifecycle.OriginToggle, inputSource);

        return root.requestOpen(inputSource);
    }

    // The window adapter calls this once its mapped surface can safely accept
    // focus. Mapping and focus readiness are not assumed to be synchronous.
    function notifySurfaceReady(): void {
        if (!internal.requestedOpen)
            return;

        internal.surfaceReady = true;
        root.requestFocusEntryIfReady();
    }

    function requestFocusEntryIfReady(): void {
        if (!internal.requestedOpen || internal.lifecycleState === DisclosureLifecycle.Closed || !internal.surfaceReady || internal.focusEntrySent || !root.focusOnOpen)
            return;

        internal.focusEntrySent = true;
        root.focusEntryRequested(root.focusTarget, internal.openInputSource);
    }

    function shouldRestoreFocus(reason: int, inputSource: int, explicitRestore: bool): bool {
        if (reason === DisclosureLifecycle.Escape)
            return true;

        if (reason === DisclosureLifecycle.OriginToggle)
            return inputSource !== DisclosureLifecycle.Pointer;

        if (reason === DisclosureLifecycle.Programmatic)
            return explicitRestore;

        return false;
    }

    function startTransition(targetProgress: real): void {
        openingTransition.stop();
        closingTransition.stop();

        if (internal.completingTransition) {
            internal.pendingTarget = targetProgress;
            if (!internal.transitionStartScheduled) {
                internal.transitionStartScheduled = true;
                Qt.callLater(() => {
                    internal.transitionStartScheduled = false;
                    root.startTransition(internal.pendingTarget);
                });
            }
            return;
        }

        if (root.reducedMotion || root.transitionDuration <= 0) {
            internal.transitionProgress = targetProgress;
            root.settleTransition();
            return;
        }

        const distance = Math.abs(targetProgress - internal.transitionProgress);
        if (distance === 0) {
            root.settleTransition();
            return;
        }

        const activeTransition = targetProgress === 1 ? openingTransition : closingTransition;
        activeTransition.from = internal.transitionProgress;
        activeTransition.duration = Math.max(1, Math.round(root.transitionDuration * distance));
        activeTransition.easing.type = root.transitionEasing;
        activeTransition.start();
    }

    function settleTransition(): void {
        if (internal.requestedOpen) {
            if (internal.transitionProgress !== 1) {
                internal.lifecycleState = DisclosureLifecycle.Opening;
                root.startTransition(1);
                return;
            }

            internal.lifecycleState = DisclosureLifecycle.Open;
            root.opened();
            return;
        }

        if (internal.transitionProgress !== 0) {
            internal.lifecycleState = DisclosureLifecycle.Closing;
            root.startTransition(0);
            return;
        }

        const reason = internal.lastDismissalReason;
        const restoreFocus = internal.restoreFocusOnClose;
        const closingOrigin = internal.activeOrigin;

        internal.lifecycleState = DisclosureLifecycle.Closed;
        internal.activeOrigin = null;
        internal.focusEntrySent = false;
        internal.surfaceReady = false;
        internal.restoreFocusOnClose = false;

        DisclosureCoordinator.release(root);

        if (restoreFocus && closingOrigin !== null && closingOrigin.visible && closingOrigin.enabled)
            root.focusRestorationRequested(closingOrigin, reason);

        root.unmappingRequested();
        root.closed(reason);
    }

    function validateOrigin(): void {
        if (!root.effectiveOpen)
            return;

        const usable = root.origin !== null && root.origin.visible && root.origin.enabled && root.originAvailable;
        if (!usable || root.origin !== internal.activeOrigin)
            root.requestClose(DisclosureLifecycle.OriginUnavailable);
    }

    onOriginChanged: validateOrigin()
    onOriginAvailableChanged: validateOrigin()

    onScopeIdChanged: {
        if (root.effectiveOpen)
            root.requestClose(DisclosureLifecycle.OriginUnavailable);
    }

    onExclusiveInScopeChanged: {
        if (!exclusiveInScope) {
            DisclosureCoordinator.release(root);
        } else if (requestedOpen) {
            DisclosureCoordinator.activate(root);
        }
    }

    onReducedMotionChanged: {
        if (!reducedMotion || (!openingTransition.running && !closingTransition.running))
            return;

        openingTransition.stop();
        closingTransition.stop();
        internal.transitionProgress = internal.requestedOpen ? 1 : 0;
        settleTransition();
    }

    property Connections originConnections: Connections {
        target: root.origin
        enabled: target !== null
        ignoreUnknownSignals: true

        function onVisibleChanged(): void {
            root.validateOrigin();
        }

        function onEnabledChanged(): void {
            root.validateOrigin();
        }

        function onDestroyed(): void {
            if (root.effectiveOpen)
                root.requestClose(DisclosureLifecycle.OriginUnavailable);
        }
    }

    property NumberAnimation openingTransition: NumberAnimation {
        target: internal
        property: "transitionProgress"
        to: 1

        onFinished: {
            if (internal.requestedOpen) {
                internal.completingTransition = true;
                root.settleTransition();
                internal.completingTransition = false;
            }
        }
    }

    property NumberAnimation closingTransition: NumberAnimation {
        target: internal
        property: "transitionProgress"
        to: 0

        onFinished: {
            if (!internal.requestedOpen) {
                internal.completingTransition = true;
                root.settleTransition();
                internal.completingTransition = false;
            }
        }
    }

    property QtObject internal: QtObject {
        property bool requestedOpen: false
        property int lifecycleState: DisclosureLifecycle.Closed
        property real transitionProgress: 0
        property int lastDismissalReason: DisclosureLifecycle.NoDismissal
        property int openInputSource: DisclosureLifecycle.ProgrammaticInput
        property Item activeOrigin: null
        property bool focusEntrySent: false
        property bool surfaceReady: false
        property bool restoreFocusOnClose: false
        property bool completingTransition: false
        property bool transitionStartScheduled: false
        property real pendingTarget: 0
    }

    Component.onDestruction: DisclosureCoordinator.release(root)
}

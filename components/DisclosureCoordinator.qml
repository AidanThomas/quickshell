pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property string defaultScope: "shell"

    property var activeByScope: ({})

    signal activeDisclosureChanged(string scopeId, var disclosure)

    function normalizedScope(scopeId: string): string {
        return scopeId.length > 0 ? scopeId : root.defaultScope;
    }

    function activeDisclosure(scopeId = root.defaultScope): var {
        return root.activeByScope[root.normalizedScope(scopeId)] ?? null;
    }

    function activate(disclosure: var): void {
        if (disclosure === null || disclosure === undefined || !disclosure.exclusiveInScope)
            return;

        const scopeId = root.normalizedScope(disclosure.scopeId);
        let active = root.activeDisclosure(scopeId);
        if (active === disclosure)
            return;

        // Remove stale registration for this disclosure before assigning its
        // current scope. This also makes changing scope deterministic.
        root.release(disclosure);
        active = root.activeDisclosure(scopeId);

        if (active !== null) {
            active.requestClose(DisclosureLifecycle.Replacement, DisclosureLifecycle.ProgrammaticInput);
        }

        const next = Object.assign({}, root.activeByScope);
        next[scopeId] = disclosure;
        root.activeByScope = next;
        root.activeDisclosureChanged(scopeId, disclosure);
    }

    function release(disclosure: var): void {
        if (disclosure === null || disclosure === undefined)
            return;

        const next = Object.assign({}, root.activeByScope);
        const releasedScopes = [];

        for (const scopeId of Object.keys(next)) {
            if (next[scopeId] !== disclosure)
                continue;

            delete next[scopeId];
            releasedScopes.push(scopeId);
        }

        if (releasedScopes.length === 0)
            return;

        root.activeByScope = next;
        for (const scopeId of releasedScopes)
            root.activeDisclosureChanged(scopeId, null);
    }

    function requestOpen(disclosure: var, inputSource = DisclosureLifecycle.ProgrammaticInput): bool {
        if (disclosure === null || disclosure === undefined)
            return false;

        return disclosure.requestOpen(inputSource);
    }

    function requestClose(disclosure: var, reason = DisclosureLifecycle.Programmatic, inputSource = DisclosureLifecycle.ProgrammaticInput, restoreFocus = false): bool {
        if (disclosure === null || disclosure === undefined)
            return false;

        return disclosure.requestClose(reason, inputSource, restoreFocus);
    }

    function toggle(disclosure: var, inputSource = DisclosureLifecycle.ProgrammaticInput): bool {
        if (disclosure === null || disclosure === undefined)
            return false;

        return disclosure.toggle(inputSource);
    }
}

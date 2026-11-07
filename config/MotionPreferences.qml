pragma Singleton

import Quickshell

Singleton {
    // This remains mutable so a future settings surface can update it without
    // changing disclosure consumers. The environment value supplies a useful
    // session-level input until that preference UI exists.
    property bool reducedMotion: environmentRequestsReducedMotion()

    function duration(normalDuration: int): int {
        return reducedMotion ? 0 : normalDuration;
    }

    function environmentRequestsReducedMotion(): bool {
        const value = (Quickshell.env("QUICKSHELL_REDUCED_MOTION") ?? "").trim().toLowerCase();
        return value === "1" || value === "true" || value === "yes" || value === "on";
    }
}

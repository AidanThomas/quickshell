pragma Singleton

import Quickshell

Singleton {
    enum Mode {
        Minimum,
        Compact,
        Full
    }

    readonly property int minimumSupportedWidth: 800
    readonly property int compactWidth: 960
    readonly property int fullWidth: 1280
    readonly property real minimumSupportedScale: 1
    readonly property real maximumSupportedScale: 2.5

    readonly property string preferredPrimaryName: (Quickshell.env("QUICKSHELL_PRIMARY_MONITOR") ?? "").trim()

    function modeForWidth(width: real): int {
        if (width >= fullWidth)
            return LayoutPolicy.Full;
        if (width >= compactWidth)
            return LayoutPolicy.Compact;
        return LayoutPolicy.Minimum;
    }

    function isPrimaryScreen(screen: var, screens: var): bool {
        if (!screen)
            return false;

        if (preferredPrimaryName.length > 0)
            return screen.name === preferredPrimaryName;

        // Hyprland has no persistent primary-output flag. The output containing
        // the compositor origin is the stable convention used by this shell.
        if (screen.x === 0 && screen.y === 0)
            return true;

        return screens?.length > 0 && screens[0] === screen;
    }

    function primaryScreens(screens: var): list<var> {
        const values = Array.from(screens ?? []);
        const preferred = values.filter(screen => isPrimaryScreen(screen, values));
        return preferred.length > 0 ? [preferred[0]] : (values.length > 0 ? [values[0]] : []);
    }

    function secondaryScreens(screens: var): list<var> {
        const values = Array.from(screens ?? []);
        const primary = primaryScreens(values)[0] ?? null;
        return values.filter(screen => screen !== primary);
    }
}

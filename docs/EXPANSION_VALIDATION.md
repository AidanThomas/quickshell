# Expansion and Disclosure Validation

## Session

Validated in the live Hyprland session on 2026-11-05, using Quickshell's
running repository configuration rather than a standalone QML harness.

- Hyprland 0.56.2
- Quickshell running from this checkout
- Primary output: DP-1, 2560x1440 at 1.25 scale
- Secondary rotated output: DP-3
- Hyprglass 1.0.0
- Active MPRIS media player, Cava, notifications, and application content
- Mouse and virtual Wayland pointer/keyboard input; no touchpad was present

`wlrctl` was used to inject events through Wayland's virtual pointer and
keyboard protocols. This was necessary because `hyprctl sendshortcut` targets
the active application and does not faithfully exercise focused layer-shell
surfaces.

## Results

| Area | Result | Notes |
| --- | --- | --- |
| Pointer activation | Pass | Media and notifications open and close from their real bar origins. |
| Keyboard traversal | Pass | The global bar shortcut focuses media; `Tab` advances to audio. |
| Keyboard activation | Pass | Both `Return` and `Space` open media. |
| Escape and focus restoration | Pass | `Escape` closes a keyboard-opened surface and returns focus to the media origin. |
| Pointer focus behavior | Pass | Pointer close/click-away does not force keyboard focus back to the origin. |
| Origin reactivation | Pass | Reactivating the media origin closes its disclosure normally. |
| Click-away | Pass | Outside activation closes the active disclosure; after closing, the bar and application receive pointer input normally. |
| Exclusivity | Pass | Media and notifications were never interactive at the same time. |
| Pointer handoff between origins | Qualified | With notifications holding `HyprlandFocusGrab`, the first click on media dismisses notifications and is consumed by the compositor; a second click opens media. |
| Rapid reversal | Pass | Repeated 60 ms media activations settled closed without flicker, stale input, or a mapped transparent surface. Lifecycle parity is covered by the automated resilience tests. |
| Reload resilience | Pass | A hot reload left no stale focus grab, input mask, or mapped disclosure. |
| Hyprglass enabled | Pass | Media and notification connectors meet their origins without an overlapping-glass seam. |
| Hyprglass disabled | Pass | Geometry and shared-edge treatment remain intact without the plugin. The plugin was reloaded and verified afterward. |
| Concurrent visual load | Pass | Motion remained smooth with Cava, playing video, MPRIS updates, and application content active. |
| Runtime logs | Pass | A fresh hot reload logged only `Configuration Loaded`; no binding-loop, destroyed-object, focus, or layer-shell warnings were emitted. |

The pointer handoff qualification is a focus-grab/compositor behavior, not a
stale disclosure state: the current disclosure closes completely and the next
activation opens the requested origin. Direct coordinator replacement remains
covered by the lifecycle/coordinator tests. Improving this to a one-click
cross-origin handoff would require the adapter to treat the shell bar as part of
the focus-grab set or provide an equivalent compositor-specific bridge.

## Captured evidence

The validation run captured local screenshots for:

- pointer-opened media;
- pointer-opened notifications;
- notification-to-media dismissal/handoff;
- `Return`- and `Space`-opened media;
- focus restoration after `Escape`;
- bar `Tab` traversal;
- rapid reversal final state; and
- media with Hyprglass disabled.

The captures are kept out of the repository because they contain the user's
live application content. They were written under
`/tmp/quickshell-validation/` for review during the validation session.

## Revalidation notes

Use a real Wayland input path for this check. In particular, do not infer
keyboard behavior from `hyprctl sendshortcut`, because it sends to the active
application rather than necessarily following layer-shell keyboard focus.

For a clean log check, trigger a no-content hot reload and inspect a fresh time
window. Older log history may contain transient QML errors from development
reloads and should not be attributed to the current generation.

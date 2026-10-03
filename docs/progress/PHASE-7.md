# Phase 7: Popup Redesign

Phase 7 extends the island design system into the denser popup surfaces.

## Shared popup surface

- Added `components/PopupSurface.qml` as the popup counterpart to `WidgetIsland`.
- Uses the more opaque popup surface token, shared radius and border tokens, standard 16px padding, and a restrained cyan top edge.
- A short connector above the panel visually relates anchored popups to their originating island.

## Audio

- Output and input sections use cyan and blue labels, semantic amber mute states, subtle dividers, and compact controls.
- Device selectors now use shared geometry, focus/hover borders, and cyan selection markers.
- Sliders use a subdued track with cyan progress and interactive handle feedback.
- Stream-row bindings now safely handle nodes whose audio object disappears during PipeWire model updates.

## Media

- The popup uses the shared surface and spacing.
- Metadata hierarchy is stronger: title is primary, artist secondary, and album is blue supporting metadata.
- Progress, transport, and volume controls share the cyan active state, muted supporting text, and pointer feedback.
- Popup sizing now uses implicit dimensions, removing the previous Quickshell deprecation warnings.

## Notifications

- The notification centre uses the shared popup surface with an uppercase technical header and compact actions.
- Cards use raised translucent surfaces, fine outlines, hover transitions, and red borders only for critical urgency.
- App name, timestamp, summary, and body now have distinct hierarchy; long bodies are limited to four lines.
- Dismissal gains red hover feedback without making the whole neutral card destructive.

## Power

- The existing placeholder is presented on the shared red-accented popup surface.
- No destructive system actions were invented or enabled during this styling phase.
- `PowerWidget` remains unmounted in the current bar layout.

## State and placement

- Player, volume, and notification islands retain their active state for the lifetime of their popup.
- Anchored audio and media popups inherit placement from their originating controls.
- The notification panel was verified at `(2155, 45)` with size `400 x 1385` on the active 2560x1440 DP-1 bar monitor, preserving its right and bottom margins.
- The second monitor does not host a bar instance, so it has no originating islands or popups to clip.

## Validation

- Quickshell reloads successfully without new errors.
- `git diff --check` passes.
- Temporary forced-open test states were restored.
- `phase7-notification-center.png` records the full multi-monitor placement check. The audio capture was not retained as evidence because Quickshell does not reliably instantiate a forced-visible anchored `PopupWindow` during hot reload; natural click activation remains the valid path.

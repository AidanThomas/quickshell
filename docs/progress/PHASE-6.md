# Phase 6: Widget-Specific Styling

Phase 6 gives each bar widget a distinct information hierarchy while retaining the shared island language and semantic colour system.

## Workspaces

- Active, occupied, and empty dots now reference semantic workspace tokens.
- The sliding indicator and directional smear are unchanged.
- The island follows the row's implicit width as workspaces 6–10 appear or disappear.
- Workspace movement briefly activates the island's cyan edge treatment.
- Existing full-slot click targets remain intact.

## Audio visualizer

- Bars transition tonally from cyan to blue across the island.
- One-pixel spacing keeps the 32-bar display compact.
- Low and zero levels use reduced opacity, avoiding a bright idle baseline.
- The existing delayed `cava` restart path remains active.

## Media

- Track title is the high-contrast primary line; artist is a compact muted secondary line.
- A narrow cyan marker indicates playback and contracts to muted grey while paused.
- Empty metadata and unavailable-player copy are defined.
- A fixed 280px content width and right elision prevent long metadata from moving neighbouring islands.

## Notifications

- Idle is neutral, unread is amber, do-not-disturb is muted, and explicit critical urgency is red.
- Counts cap visually at `99+` to keep the island stable.
- Semantic state also propagates to the island border and accent edge.

## Volume

- Normal speaker state uses cyan while the microphone remains secondary.
- Muted input or output switches the corresponding control to amber and marks the island for attention.
- Existing left-click popup, right-click mute, and wheel volume targets are unchanged.

## Clock and power

- The split clock keeps time dominant and metadata secondary, with slightly tighter spacing and sizing inside its island.
- The unmounted power widget stays neutral while idle and exposes a red open-state treatment. Its hit target remains limited to the icon bounds. The placeholder menu contains no destructive commands yet; those controls belong to the popup work in Phase 7.

## Validation

- Quickshell reloaded successfully with no new runtime errors.
- `git diff --check` passes.
- The full bar was reviewed against both dark terminal content and a bright, saturated desktop background.
- Existing null-state audio/player warnings remain baseline issues and are unrelated to this styling pass.

## Capture

- `phase6-widget-styling.png`: complete bar after the widget-specific styling pass.

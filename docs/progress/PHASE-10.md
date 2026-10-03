# Phase 10: Accessibility and Resilience

Phase 10 hardens transient service lifecycles, improves contrast and target sizing, and checks the bar outside its ideal data state.

## Readability and interaction

- Increased top-bar island opacity while retaining translucency and compositor blur.
- Raised muted text from `#82909A` to `#AEBAC2`, preserving hierarchy while improving legibility over bright backgrounds.
- Reviewed the complete bar over the saturated blue wallpaper and bright application chrome at native bar size.
- Notification, microphone, speaker, and unmounted power controls now retain at least a 24px interaction dimension where their glyph bounds were previously smaller.
- Workspace targets remain 24px tall, retain their full slot hit area, and preserve the deliberately compact horizontal spacing.

## Meaning beyond colour

- Active workspaces remain filled; occupied inactive workspaces now also use a heavier outline in addition to blue.
- Speaker and microphone mute states change glyph as well as colour.
- Do-not-disturb changes the notification glyph and label.
- Playback changes both the icon/marker geometry and colour.
- Critical notification cards prefix their application label with `CRITICAL` in addition to using a red outline.
- Unread notification state includes a numeric count rather than relying on amber alone.

## Service lifecycle resilience

- Simulated a missing Spotify MPRIS player. The media island disappeared normally and reloads remained warning-free.
- Simulated null PipeWire input and output endpoints. The volume widget displayed fallback icons and `--%` without warnings.
- Restored the live PipeWire bindings after the null-endpoint load. Devices recovered immediately, exercising the same late-availability binding path without interrupting the user's real audio service.
- Audio popup and stream bindings now guard both the node and its transient `audio` object.
- Player progress connections now use a nullable target and a valid position signal; boolean capability expressions always resolve to true or false.
- Transport actions re-check capability at click time in case the player disappears between display and activation.
- Simulated notification delegates whose tracked object had disappeared. Cards rendered safe fallback content without recurring warnings.

## Reload and monitors

- Reloaded the configuration while the notification centre was instantiated in its open state; configuration loaded successfully and normal closed state was restored afterward.
- Verified the live two-monitor layout after reload: DP-1 is 2560x1440 at scale 1 with the 40px bar reservation; DP-3 is rotated with transform 3 at scale 1 and intentionally has no bar instance.
- Physical connect/disconnect and live scale mutation were not automated because either operation can migrate the user's active windows and workspace 11. This remains the one manual regression check in the phase checklist.

## Validation

- All simulated service and notification states were restored to live bindings.
- Repeated reloads completed without redesigned-component warnings.
- `git diff --check` passes.
- `phase10-missing-services.png` records the null audio/missing-player state.
- `phase10-bright-background.png` records the final contrast review.

# Phase 9: Motion and Performance Pass

Phase 9 standardizes motion by purpose and verifies that rapid interaction does not compromise state or performance.

## Motion system

All timing and easing choices now live in `Theme.qml`:

- Hover feedback: 180ms.
- Semantic state changes: 200ms.
- Positional movement: 300ms.
- Visualizer response: 45ms.
- Standard reversible motion: `InOutSine`.
- Entering panels and toasts: `OutCubic`.
- Fast data response: `OutSine`.

Colour, opacity, workspace, popup, toast, player, volume, and device-selector transitions now reference these shared roles. The visualizer remains intentionally faster so it tracks audio instead of lagging behind it.

## Animation audit

- No decorative infinite animations are present.
- Workspace movement communicates selection and direction.
- Hover and focus transitions communicate interactivity.
- Popup and toast movement communicates appearance, dismissal, and stacking.
- Player and volume transitions communicate playback or mute state.
- The audio visualizer is the sole ambient motion source and directly represents audio levels.
- Notification attention does not pulse repeatedly; it makes one finite 200ms transition into amber or critical state and remains stable.

## Render-thread animator decision

Qt render-thread animators were considered for the workspace indicator. They were not adopted because the directional smear derives its geometry from the indicator's live intermediate position and width. Render-thread animators update the rendered transform independently of the QML property, which would make interrupted transitions and smear direction disagree. The existing property animation preserves correct reversible geometry and passed the stress test.

## Stress test

- Reversed between occupied workspaces 1 and 2 ten times at 60ms intervals, substantially faster than the 300ms transition duration.
- The indicator reversed from its intermediate position, did not jump, and settled on workspace 1.
- The directional smear did not remain elongated or overlap after the animation completed.
- Hover behavior was previously verified over the active visualizer in Phase 5; the shared surface animation path now uses the same centralized easing without altering hit testing.
- The configured Lua dispatcher rejected synthetic pointer movement in this pass, so no false automated hover result was recorded. The cursor never moved from its original `(1887, 515)` position.

## Performance sample

Sampled during active browser audio and normal desktop use:

| Process | CPU | Memory |
| --- | ---: | ---: |
| Quickshell | 1.1% | 0.5% |
| cava | 1.3% | 0.0% |

The NVIDIA per-process sample listed Quickshell as a graphics client without independently measurable utilization. Total GPU utilization was 28%, with the browser, compositor, Discord, Steam, and other graphics clients active; this total cannot be attributed to the bar.

## Validation

- Original workspace and cursor state were preserved after testing.
- Quickshell reloads successfully.
- `git diff --check` passes.

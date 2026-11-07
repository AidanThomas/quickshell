# Shell Motion System

## Status and purpose

This document defines the motion roles used by the shell. It completes the design
contract for issue #17 by translating the principles in `DESIGN.md`,
`INTERACTION_GRAMMAR.md`, `EXPANSION.md`, `BAR_COMPOSITION.md`, and
`VISUAL_IDENTITY.md` into implementation and validation rules.

Motion is evidence of a change, not decoration applied to an otherwise static
element. Every animation must identify the state change, destination, spatial
relationship, or genuinely live value that it communicates. A transition without
one of those purposes should be removed.

## Roles

| Role | Meaning | Normal treatment | Reduced-motion treatment |
| --- | --- | --- | --- |
| Feedback | Immediate acknowledgement of hover, press, or focus. | Brief non-spatial color, outline, or opacity response. | Immediate or an equally brief non-spatial response. |
| State | A semantic value changed without changing the composition. | Short color, opacity, or local indicator interpolation. | Immediate final state; semantic meaning remains visible. |
| Spatial | An element changed position, ordering, or occupied composition. | Smooth directional movement from the current geometry. | Immediate final geometry, optionally accompanied by a brief fade. |
| Disclosure | A compact origin reveals or hides a related surface. | Shared lifecycle progress reveals from the measured origin and shared edge. | The same lifecycle settles immediately without spatial travel. |
| Transient | Information arrives, departs, or changes order for a bounded lifetime. | Directional arrival/departure or ordering motion without overshoot. | Immediate placement or removal; no delayed cleanup. |
| Ambient | A value is genuinely and continuously live. | Responsive interpolation that yields to actionable information. | Stop non-essential motion while retaining the widget's place. |

These roles do not require every consumer to use an identical animation. They
constrain why motion exists and which shared duration and easing family it uses.

## Implementation tokens

`Theme.qml` exposes semantic duration and easing pairs for `Feedback`, `State`,
`Spatial`, `Disclosure`, `Transient`, and `Ambient`. Consumers resolve durations
through `MotionPreferences.duration()`. Code must not reuse a role merely because
its duration happens to look convenient, or introduce a local overshooting easing
for routine shell motion.

The disclosure lifecycle owns disclosure timing and progress. Presentations consume
that progress; they do not create a second open state or authorize mapping, input,
focus, or cleanup from a local animation callback.

## Current animation audit

| Area | Role and decision |
| --- | --- |
| Island and action hover, outlines, shadows | Feedback; retain as non-spatial response. |
| Muted, unavailable, attention, critical, playing, and open presentation | State; retain color, opacity, and local indicator changes. |
| Workspace selection | Spatial; retain because direction and destination are meaningful. It must reverse from its current position. |
| Centre media occupancy | Spatial plus state fade; retain because regional membership changed. Side regions remain fixed. |
| Popup and panel reveal | Disclosure; retain the shared reversible lifecycle and origin geometry. |
| Notification toast arrival, departure, and stack movement | Transient; retain directional travel, remove overshoot, and keep cleanup synchronized with the role. |
| Cava bars | Ambient; retain only while normal motion is allowed and live data is available. |
| Routine text, time, count, title, and volume changes | No geometric motion. They may use a state color response but must not resize regional material continuously. |
| Per-widget startup scale or opacity flourish | No structural role; do not use. The shell is usable at its final composition immediately. |

## Interruption and geometry

Spatial, transient, and disclosure motion starts from the current rendered state.
A newer request supersedes an older one without snapping to an endpoint, replaying
an entrance, briefly unmapping, or allowing a stale completion callback to win.

Contextual centre content is independently centred on the output. Its appearance
and disappearance may change centre material but never moves the left or right
regions. Frame-only and visually empty spans remain click-through throughout the
transition and after interruption.

Persistent hover, focus, press, and semantic feedback never translates, lifts,
scales, or resizes bar content. A geometry change is reserved for a real change in
composition, position, ordering, or disclosure extent.

## Reduced motion

Reduced motion is a live preference and applies to every current animation. When it
is enabled, the shell:

- removes travel, scale, spring, and overshoot;
- settles spatial and disclosure changes without perceptible duration;
- stops non-essential ambient visualization;
- preserves focus, open, attention, critical, progress, and availability feedback;
- preserves membership, final geometry, mapping, dismissal, and input regions; and
- never delays interaction or cleanup to preserve an animation timeline.

Changing the preference during a transition settles that transition at the latest
requested endpoint. Re-enabling normal motion affects later changes; it does not
replay motion that was skipped.

## Validation and completion criteria

The motion foundation is complete when:

- every live animation maps to an audited role and shared semantic token;
- no per-widget startup flourish or routine overshooting transition remains;
- workspace, centre occupancy, disclosure, toast, and ambient examples prove the
  roles in the running shell;
- rapid reversal, replacement, contextual-content churn, and a reduced-motion
  change during transition settle at the latest requested state;
- normal and reduced motion produce identical final geometry, lifecycle, focus,
  input, and semantic states;
- notification cleanup does not depend on an obsolete hard-coded animation delay;
- Cava, media changes, notification activity, and active-window changes remain
  responsive together with Hyprglass enabled and disabled; and
- a clean startup and hot reload produce no QML errors, binding loops, stale focus,
  stale material, or invisible input regions.

Future calendar, launcher, system, and overview work consumes these roles. Their
feature implementation is not required to prove this foundation.

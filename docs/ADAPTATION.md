# Shell Adaptation Baseline

## Status and purpose

This document defines the responsive, multi-monitor, keyboard, motion, and
resilience baseline for issue #18. It gives new widget work a stable contract;
it does not require every future compact presentation to exist in advance.

## Supported display baseline

The full bar supports output widths from 800 through 3840 logical pixels and
output scales from 1 through 2.5. Wider, narrower, or differently scaled outputs
remain usable through the minimum layout, but are outside the actively validated
baseline. Decisions use logical geometry, so scale changes do not require a
parallel set of physical-pixel breakpoints.

`LayoutPolicy` exposes three profiles:

| Profile | Logical width | Composition |
| --- | --- | --- |
| Full | 1280 and above | Normal three-region composition. |
| Compact | 960–1279 | Removes ambient visualization before actionable content. |
| Minimum | Below 960 | Preserves workspaces, time, audio, and meaningful notification state; contextual media and quiet notification state yield. |

At widths below 800, the minimum profile is the graceful fallback rather than a
promise that every combination of exceptional state fits without truncation.
Content continues to compact and hide in the order defined by
`BAR_COMPOSITION.md`. Critical, privacy, and safety meaning is never removed.

The primary canopy remains attached to the top output edge at every profile.
Geometry is recomputed directly from current logical output bounds after a width,
scale, or rotation change; stale physical dimensions are never cached.

## Output roles

Exactly one current output owns the full, interactive shell. Selection uses:

1. `QUICKSHELL_PRIMARY_MONITOR`, when explicitly set to a current output name;
2. the output containing compositor origin `(0,0)`; or
3. the first current output as a hotplug fallback.

This avoids a required hard-coded connector name while allowing an explicit local
override. Every other output, landscape or portrait, receives a non-exclusive,
click-through glance surface containing time and date. Secondary surfaces never
take keyboard focus, reserve working area, expose controls, or host disclosures.

Screen variants follow `Quickshell.screens`, so connection, removal, rotation,
logical-size, and scale changes apply immediately. There is no debounce or
animation between output roles. If the primary disappears, the fallback output is
promoted immediately; if it returns, normal selection is evaluated again.

## Keyboard and accessible interaction

Only the primary bar participates in keyboard navigation. The `focusBar` global
shortcut or `bar.focus()` IPC entry enters the bar. `Tab` and `Shift+Tab` follow
the visual control order, `Space` or `Enter` activates the focused control, and
`Escape` closes the active disclosure or exits bar navigation. Arrow keys are
reserved for controls whose internal value or structure requires them, such as a
calendar grid or slider; they do not create a second bar-navigation model.

Interactive controls provide a visible non-colour-only focus outline, forgiving
targets, accessible names, and semantic state descriptions. Hidden responsive
content leaves the tab chain. Pointer activation does not manufacture keyboard
focus, and secondary glance surfaces are absent from the focus chain.

## Motion

The role and reduced-motion rules in `MOTION.md` apply without display-specific
exceptions. Responsive and output-role changes settle at their final geometry
immediately. Reduced motion removes travel and ambient animation while preserving
membership, semantic state, focus, and spatial understanding through stable edge
attachment and final placement.

## Resilience contract

- Monitor connector names are optional configuration, never an unconditional
  assumption in widget code.
- Components consume current screen geometry and shared layout profiles instead
  of fixed monitor dimensions.
- Missing or delayed services produce unavailable or quiet states without
  changing unrelated output roles.
- Shell assets resolve relative to the configuration, not an absolute home path.
- Output removal cannot leave focus, an input mask, exclusive space, or a canopy
  presenter on a destroyed screen.
- Normal and reduced motion reach identical layout and input state.

## Validation

Validate the baseline at 800, 960, 1280, 2560, and 3840 logical pixels and at
scales 1, 1.5, 2, and 2.5 where supported. Exercise primary and secondary
landscape outputs, a portrait secondary, primary removal and return, rotation,
scale changes, keyboard entry/traversal/activation/escape, exceptional states at
minimum width, reduced motion, and a hot reload. Each run must remain free of QML
errors, binding loops, stale reservations, invisible input regions, and focus on
secondary surfaces.

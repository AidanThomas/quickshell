# Bar Visual Identity

## Status and purpose

This document records the visual-system direction for issue #16. It explains how
bar widgets can acquire purposeful identities without losing the family
resemblance that makes the bar read as one shell surface.

`DESIGN.md` remains the source for overall character. `BAR_COMPOSITION.md`
decides membership, placement, and occupancy. `INTERACTION_GRAMMAR.md` and
`EXPANSION.md` remain authoritative for behavior and disclosure lifecycle. This
document concerns the material and compositional relationship between those
elements.

## Visual hierarchy

The bar uses three layers of identity:

1. A narrow screen-edge frame remains continuous across the display. It gives
   separated regions a common datum without filling unused space with glass.
2. Regional glass surrounds occupied navigation, current-activity, and system
   groups. These regions establish the bar's large-scale rhythm.
3. Widgets communicate their task primarily through internal composition,
   density, division, typography, and semantic accents.

The frame is the strongest expression of family resemblance. Individual widgets
therefore do not need unrelated silhouettes or ornamental outlines to become
recognisable.

## Regional material

The left and right regions retain stable positions and size themselves around
their normal members. The centre region is independently anchored to the physical
centre of the output and exists only while qualifying contextual content exists.
Media appearing or disappearing changes the centre material; it never pushes the
side regions.

When a region is unoccupied, its broad glass fill is absent and only the narrow
frame continues through that span. The empty area is intentional desktop space,
not a missing or loading surface.

Region membership changes may animate as a bounded material transition. Routine
content changes such as a clock tick, volume value, notification count, or track
title must not continuously resize regional material. Reduced motion resolves the
same final geometry without spatial travel.

The visual extent and input extent of occupied material are related but not
interchangeable. Frame-only and empty spans remain click-through. An invisible or
zero-width contextual region must not retain an input region.

## Shared base and permitted variation

The bar deliberately keeps most of its language common:

- one material and depth hierarchy;
- one height, alignment, spacing, and corner family;
- shared typography and icon treatment;
- shared hover, pressed, focused, open, unavailable, attention, and critical
  semantics;
- shared motion roles and disclosure lifecycle; and
- shared accent palette.

Variation occurs in three increasingly exceptional levels:

| Level | Permitted variation | Use |
| --- | --- | --- |
| Shared base | Material, height, alignment, state treatment, and spacing | Nearly every bar element |
| Compositional pattern | Internal layout, density, division, and meaningful accent placement | Normal widget differentiation |
| Structural exception | Exposed regional content, shared edges, or a modified silhouette | Only when function cannot be expressed clearly inside the normal pattern |

A widget should not introduce a unique outer shape, material, or interaction
animation unless it communicates a structural fact that internal composition
cannot.

## Initial patterns

### Interactive module

Expandable or directly actionable content uses the common interactive island.
Its identity comes from its content hierarchy and semantic state rather than a
new shell. Media, notifications, and audio currently use this family.

### Repeated selection

Workspace position is expressed as a repeated, ordered set inside a common
module. Selection and occupancy belong to the individual cells, so a generic
module-wide accent should not compete with those signals.

### Ambient readout

Read-only live information may sit directly in regional glass when an additional
capsule would falsely imply interaction. The audio visualizer is the first use of
this pattern. Ambient content receives no hover, focus, or open treatment.

### Quiet readout

Time and similar orientation information share the bar's typography, alignment,
and material but remain quieter than actionable or exceptional state. Their
internal hierarchy should do more work than decorative accents.

## State and accent rules

Accents communicate selection, progress, focus, open state, attention, or
severity. They are not mandatory trim. Placement should relate to content—for
example a selected workspace cell, a media activity edge, an audio value, or a
notification count—rather than applying the same bottom line indiscriminately.

Combined dimensions remain legible. Focus does not disappear when a control is
open or critical; muted does not imply unavailable; and attention does not change
the primary action. Color is supported by geometry, iconography, text, or another
non-color cue whenever the distinction matters.

Persistent bar feedback is non-spatial. Hover, focus, and press do not lift,
translate, resize, or scale a widget. Regional occupancy may change geometry
because the composition itself changed, not merely because a pointer arrived.

## Validation and completion criteria

The visual-identity work is complete when:

- the live bar demonstrates left, optional centre, and right regional glass joined
  by the continuous frame;
- centre material appears and disappears without moving either side;
- transparent gaps and the connecting frame do not intercept pointer input;
- every current bar element has an intentional compositional pattern, including
  read-only content that does not need an island;
- practical hit targets, keyboard order, semantic states, and disclosure behavior
  remain consistent with the interaction and expansion contracts;
- ordinary content updates do not cause distracting material reflow;
- the result remains legible over bright, dark, and busy backgrounds, with
  compositor glass effects enabled and disabled;
- reduced motion preserves the same membership, geometry, input, and semantic
  states without spatial animation;
- responsive reduction follows `BAR_COMPOSITION.md` and never discards critical,
  privacy, or safety information; and
- a clean reload produces no QML errors, binding loops, stale focus, or stale input
  regions.

Future launcher, calendar, system, and workspace-overview work should adopt or
deliberately extend these patterns. Their implementation is not required to prove
this model on the current bar.

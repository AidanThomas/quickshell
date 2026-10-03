# Bar Feedback Revision Plan

## Objective

Refine the current design into a quieter, more cohesive dark-glass interface. The bar should feel like one environmental surface containing consistently sized instrument modules, with colour reserved for meaningful state rather than decoration.

This pass addresses three connected concerns:

1. Excessive cyan and an overdesigned audio visualizer.
2. Inconsistent widget-island heights.
3. A stronger glass effect for both the full-width bar and individual islands.

## Design Decisions

### Colour restraint

- Move the default visual language toward neutral charcoal, graphite, and cool blue-grey.
- Reserve cyan for small, meaningful active indicators:
  - Active workspace fill.
  - Playing-state marker.
  - Clock weekday.
  - Focused or open control accents where needed.
- Keep amber for mute/attention and red for critical/destructive states.
- Avoid coloured island fills in normal operation.
- Review occupied-workspace blue so it reads as a subdued secondary state rather than another accent.

### Uniform island geometry

- Introduce a single shared top-bar island height token.
- Make every visible island use that height regardless of its content.
- Vertically center content within the fixed bounds.
- Preserve content-driven widths and dynamic workspace expansion.
- Keep the bar's total height at 40px.
- Ensure fixed height does not shrink pointer targets or clip the two-line player and clock layouts.

### Layered glass material

The final visual stack should be:

```text
desktop
  -> compositor blur
    -> subtle continuous full-width glass strip
      -> denser neutral widget glass
        -> fine edge highlight and semantic state detail
          -> widget content
```

- Restore a full-width panel surface, but make it substantially lighter and more transparent than the original opaque bar.
- Use the panel mainly to establish a continuous blur field and stable contrast.
- Keep islands visibly denser than the panel so they retain separation.
- Add a restrained top-edge or inner-edge highlight to islands to suggest glass thickness.
- Keep the technical clipped-corner silhouette.
- Avoid bright white gloss, large shadows, glow, or strong coloured tinting.
- Retain denser popup surfaces for readable high-information content.

## Implementation Sequence

### Stage 1: Theme tokens

Status: **Complete**

- Add semantic tokens for:
  - Full-width glass strip.
  - Neutral island surface, hover surface, and active surface.
  - Subtle glass edge highlight.
  - Neutral visualizer bars and peaks.
  - Shared top-bar island height.
- Remove or retune any surface tokens that introduce unnecessary cyan tint.
- Keep all new values centralized in `Theme.qml`.

Acceptance checks:

- Default surfaces are perceptually neutral.
- Accent colours remain recognizable when they do appear.
- The panel and islands have a clear but subtle density difference.

Implemented token set:

| Role | Value | Intent |
| --- | --- | --- |
| `glassBarSurface` | `#30252A2E` | Very low-opacity neutral strip for the Stage 3 continuous blur field. |
| `islandSurface` | `#C4161A1E` | Neutral charcoal instrument glass. |
| `islandSurfaceHover` | `#D21B2025` | Slight density lift without accent colour. |
| `islandSurfaceActive` | `#D21A2024` | Quiet active/open surface; semantic detail remains separate. |
| `popupSurface` | `#EE15191D` | Dense readable popup glass. |
| `popupSurfaceRaised` | `#F21B2025` | Raised controls and notification cards. |
| `glassEdgeHighlight` | `#526F7A80` | Restrained cool-grey material highlight for Stage 4. |
| `visualizerBar` | `#849096` | Clearly visible neutral telemetry baseline for Stage 5. |
| `visualizerPeak` | `#C1C9CD` | Bright neutral high-level response without cyan. |
| `islandHeight` | `32` | Uniform island height within the existing 40px panel. |

Existing border tokens were shifted toward neutral grey, and `accentBlue` was desaturated to `#607A84`. Cyan, amber, and red retain their semantic values so genuine state remains immediately recognizable.

### Stage 2: Uniform island sizing

Status: **Complete**

- Update `WidgetIsland` to use the shared fixed height.
- Adjust the top-bar layout to center every island consistently.
- Revisit per-widget padding overrides and remove exceptions that are no longer necessary.
- Check workspaces 6–10, long media metadata, notification counts, muted volume states, and the split clock.

Acceptance checks:

- Every top-bar island has exactly the same visible height.
- No content is clipped or visually off-center.
- Width remains responsive to each widget's needs.
- All existing click and scroll targets still work.

Implementation notes:

- `WidgetIsland` now owns the fixed `Theme.islandHeight` of 32px.
- Its content container uses content-driven width and height, centered in both axes, so individual widgets no longer determine the outer silhouette.
- Removed the visualizer's one-off vertical padding and fitted its canvas to the shared 24px internal content area.
- Existing horizontal padding exceptions remain because they tune width only and do not affect height.
- A temporary ten-workspace model confirmed that dynamic workspace expansion changes only island width; the normal active/occupied visibility rule was restored afterward.

### Stage 3: Continuous glass bar

Status: **Complete**

- Give `TopBar` a low-opacity neutral surface across its full width.
- Confirm the existing Hyprland blur rule affects the continuous strip.
- Tune panel opacity against bright, dark, and visually busy wallpaper regions.
- Ensure the strip does not read as a return to the old opaque bar.

Acceptance checks:

- The desktop remains clearly visible through the bar.
- Blur and tint improve legibility without creating a heavy band.
- Islands remain distinguishable as denser modules above the strip.

Implementation notes:

- `TopBar` now renders `Theme.glassBarSurface` (`#30252A2E`) across its full 2560x40 surface.
- The surface stays above Hyprland's `ignore_alpha = 0.1` threshold and uses the existing exact `^quickshell$` blur rule.
- The strip is substantially less opaque than the 32px islands, preserving their floating module hierarchy.
- No border or decorative separator was added to the strip; material refinement remains isolated to Stage 4.
- Removed the obsolete transparent `panelBackground` token after its final consumer migrated.

### Stage 4: Island glass refinement

Status: **Complete**

- Extend `TechnicalSurface` or `WidgetIsland` with a subtle edge highlight.
- Keep the fine neutral outline and clipped corners.
- Retune hover so it changes surface density and edge clarity rather than introducing colour.
- Keep active/open feedback small and semantic, using the existing lower-left accent line where appropriate.
- Apply the same material logic to popup shells at a higher opacity.

Acceptance checks:

- Islands read as dark instrument glass rather than flat opaque cards.
- Hover is visible but quiet.
- Neutral islands do not compete with their content.
- Popup readability is unchanged or improved.

Implementation notes:

- `TechnicalSurface` now draws a one-pixel translucent inner highlight along the top edge and clipped top-right corner.
- The highlight uses the centralized neutral `glassEdgeHighlight` token and is shared by top-bar islands and popup shells.
- Active, attention, and open islands retain neutral outlines; their existing short lower-left line carries the semantic colour instead.
- The volume island expands that line across its lower edge while its popup is open, following the clipped-corner insets; other semantic states retain the short accent.
- Critical state remains the exception and may colour the full outline red because it communicates urgency.
- Popup shells no longer draw a full-width coloured top line. Their small origin connector remains semantic, while the shared neutral highlight supplies the glass edge.
- Hover continues to change only neutral surface density and edge clarity.
- Popup readability was checked against bright green, red, blue, and wallpaper regions with the notification centre temporarily held open; normal focus dismissal was restored afterward.

### Stage 5: Audio visualizer simplification

Status: **Complete**

- Remove the cyan-to-blue gradient.
- Use a single muted neutral blue-grey across the bars.
- Lower baseline and overall opacity.
- Allow only a small neutral brightness increase at higher levels.
- Keep the existing responsive motion and `cava` recovery behavior.
- Reassess bar count, spacing, and width only if colour reduction alone does not sufficiently calm it.

Acceptance checks:

- The visualizer reads as background telemetry.
- It does not draw the eye before media, time, notifications, or workspace state.
- Zero-level bars are barely visible.
- Motion remains smooth and audio-responsive.

Implementation notes:

- Removed the position-based cyan-to-blue gradient entirely.
- All bars now share the neutral `visualizerBar` steel-grey token.
- Audio level introduces only a 30% maximum blend toward the neutral `visualizerPeak` tone.
- Opacity now ranges from 0.40 at zero level to 0.95 at maximum level, keeping the full telemetry trace visible while giving strong audio clear emphasis.
- Retained the preferred 32-bar stereo display after comparing a narrower 24-bar experiment.
- Retained one-pixel spacing, 45ms response timing, 60fps input, and delayed Cava restart recovery.

### Stage 6: Integrated review

- Capture the complete bar over bright, dark, and busy regions.
- Compare all island heights at pixel level.
- Test hover, popup-open, mute, unread, critical, playback, and workspace-movement states.
- Verify dynamic workspaces 6–10 and long media strings.
- Check Quickshell and `cava` CPU use after adding the continuous blurred surface and edge highlights.
- Confirm no recurring QML or lifecycle warnings were introduced.

Acceptance checks:

- The bar reads as one coherent glass system.
- Neutral tones dominate normal operation.
- Colour appears only when it carries information.
- Every widget island has the same height.
- Glass effects remain restrained, readable, and performant.

## Evaluation Order

Review the changes at three checkpoints rather than waiting until the entire pass is complete:

1. **Panel prototype:** continuous strip plus two unchanged islands, to judge the amount of glass.
2. **Material prototype:** one refined glass island beside the existing island treatment.
3. **Integrated bar:** uniform sizing, neutral surfaces, and simplified visualizer together.

If the panel strip feels too heavy, reduce its opacity before weakening island contrast. If islands feel too glossy, remove the inner highlight before changing blur. This keeps the material hierarchy intact while making tuning decisions reversible.

## Explicit Non-Goals

- No layout reordering.
- No new widgets or controls.
- No change to workspace behavior.
- No power-menu functionality changes.
- No glow, animated shine, or decorative ambient effects.
- No change to Protomolecule text or explicit Nerd Font icon handling.

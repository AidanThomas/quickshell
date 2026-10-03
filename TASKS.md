# Quickshell Bar Redesign Tasks

This backlog turns the direction in [DESIGN.md](DESIGN.md) into an ordered implementation plan. Tasks are grouped so each phase leaves the shell usable and can be reviewed before the next visual layer is added.

## Definition of Done

The redesign is complete when:

- The top-level bar is transparent and each logical widget sits in a consistent floating island.
- Colours, spacing, typography, borders, and motion are driven by shared theme tokens.
- Hover, active, occupied, muted, notification, and urgent states are visually consistent.
- Blur works behind translucent surfaces without compromising readability.
- Popups use the same design language with appropriate additional opacity.
- All existing widget behaviour remains functional.
- The bar has been checked over bright and dark backgrounds and on every configured monitor.
- Quickshell loads without new QML warnings or errors.

## Phase 0: Baseline and Safety

- [x] Capture screenshots of the current bar and available popup states for before/after comparison. See `docs/baseline/BASELINE.md` for unavailable-state notes.
- [x] Record current behaviour for workspaces, media, notifications, volume, clock, and power controls.
- [x] Identify existing QML warnings that predate the redesign so regressions are easy to distinguish.
- [x] Confirm the Quickshell layer namespace used by Hyprland blur rules.
- [x] Confirm behaviour and scale on every configured monitor and orientation.

Acceptance criteria:

- A visual and behavioural baseline exists.
- Known pre-existing warnings are documented.
- The compositor target for blur is known before transparency work begins.

## Phase 1: Design Tokens

- [x] Expand `config/Theme.qml` with semantic tokens for:
  - [x] Transparent panel background.
  - [x] Default island surface.
  - [x] Hover island surface.
  - [x] Active island surface.
  - [x] Popup surface.
  - [x] Default and hover borders.
  - [x] Primary and muted text.
  - [x] Cyan, blue, amber, and red accents.
  - [x] Default island radius and border width.
  - [x] Standard island padding and gaps.
  - [x] Hover, state, and positional animation durations.
- [x] Map existing workspace colours onto the new semantic accent tokens.
- [x] Replace duplicated literal colours in widgets with theme references where practical.
- [x] Verify the palette against both bright and dark desktop content.

Acceptance criteria:

- New styling work can avoid hard-coded colours and common geometry values.
- Existing widgets retain their intended state distinctions.
- Theme names describe purpose rather than a specific widget.

## Phase 2: Reusable Island Component

- [x] Create `components/WidgetIsland.qml`.
- [x] Provide a content slot that preserves each widget's natural implicit size.
- [x] Add configurable horizontal and vertical padding.
- [x] Add the default translucent surface and fine border.
- [x] Add properties for default, hovered, active, attention, muted, and critical states.
- [x] Add an optional accent edge or corner marker.
- [x] Add restrained colour and border transitions.
- [x] Ensure islands preserve practical click targets.
- [x] Test the component with text, icons, and animated content.

Acceptance criteria:

- A widget can be wrapped without rewriting its internal layout.
- State is controlled through semantic properties rather than widget-specific colours.
- Hover and state transitions reverse cleanly during rapid interaction.

## Phase 3: Transparent Bar and Base Layout

- [x] Make the `TopBar` panel background transparent.
- [x] Review bar margins and spacing for the floating-island layout.
- [x] Wrap the workspace tracker in `WidgetIsland`.
- [x] Wrap the audio visualizer in `WidgetIsland`.
- [x] Wrap the media widget in `WidgetIsland`.
- [x] Wrap the notification widget in `WidgetIsland`.
- [x] Wrap the volume widget in `WidgetIsland`.
- [x] Wrap the clock in `WidgetIsland`.
- [x] Decide whether the power control belongs in its own island or a small system-controls group. Keep the placeholder control excluded until it has functional actions.
- [x] Ensure related controls remain grouped rather than individually boxed.
- [x] Check alignment and spacing as dynamic workspace dots appear and disappear.

Acceptance criteria:

- Every logical top-bar group appears as a distinct floating island.
- The panel between islands is fully transparent.
- Dynamic content does not cause overlap, clipping, or unstable vertical alignment.
- All existing interactions still work.

## Phase 4: Compositor Blur

- [x] Add or update the Hyprland layer rule that enables blur for the Quickshell bar.
- [x] Tune blur size and pass count.
- [x] Tune compositor noise or contrast if required to prevent banding.
- [x] Balance island alpha against the blur result.
- [x] Confirm transparent areas between islands do not receive an unwanted visible panel fill.
- [x] Check performance while the audio visualizer and workspace animation are active.
- [x] Verify blur on each monitor and over fullscreen applications. DP-3 has no current bar surface; true fullscreen covers the DP-1 bar. See `docs/progress/PHASE-4.md`.

Acceptance criteria:

- Desktop content is visibly softened behind islands.
- Text and icons remain readable over bright, detailed backgrounds.
- Blur does not introduce obvious animation stutter or excessive GPU load.
- Areas outside the islands still read as transparent.

## Phase 5: Interaction State System

- [x] Add hover state to every interactive island.
- [x] Add active/open state while a popup is visible.
- [x] Establish consistent cursor behaviour for clickable controls.
- [x] Add keyboard focus styling where controls can receive focus.
- [x] Ensure nested mouse areas do not prevent the island hover state from updating.
- [x] Verify rapid hover and popup transitions do not leave stale states.

Acceptance criteria:

- Interactive islands respond consistently to pointer and active state.
- State changes are noticeable without large saturated fills.
- Hover and active feedback does not compete with widget content.

## Phase 6: Widget-Specific Styling

### Workspaces

- [x] Integrate the existing active, occupied, and empty dot colours with semantic theme tokens.
- [x] Preserve the sliding indicator and directional trailing smear.
- [x] Ensure the island resizes cleanly for dynamic workspaces 6–10.
- [x] Consider a subtle island accent during workspace movement.
- [x] Verify all visible dots remain clickable.

### Audio visualizer

- [x] Apply a restrained cyan or cyan-to-blue tonal treatment.
- [x] Tune bar width, spacing, and opacity for the new island.
- [x] Ensure zero-level bars remain subtle rather than visually noisy.
- [x] Confirm the `cava` restart recovery remains functional.
- [x] Check that the visualizer does not cause motion stutter elsewhere in the bar.

### Media

- [x] Establish clear hierarchy between track title, artist, and playback controls.
- [x] Use muted styling for supporting metadata.
- [x] Add a small playback-state accent marker.
- [x] Define empty and unavailable-player states.
- [x] Ensure long metadata truncates gracefully without resizing the bar unexpectedly.

### Notifications

- [x] Use the default neutral state when there are no unread notifications.
- [x] Use amber for unread or attention state.
- [x] Give do-not-disturb a deliberately muted state.
- [x] Reserve red for explicitly urgent notifications.
- [x] Keep notification count legible at one, two, and three-plus digits.

### Volume

- [x] Use a neutral or cyan state for normal audio.
- [x] Use amber for muted output or input.
- [x] Distinguish microphone and speaker state without adding unnecessary colours.
- [x] Verify scrolling and clicking retain clear feedback.

### Clock

- [x] Integrate the existing split time/date layout into the island.
- [x] Preserve time as the primary high-contrast element.
- [x] Keep weekday and date secondary.
- [x] Reassess font size and spacing after island padding is applied.

### Power

- [x] Give destructive actions red accents only after the menu is opened.
- [x] Keep the idle power icon neutral.
- [x] Ensure the power menu cannot be triggered accidentally through an oversized island target.

Acceptance criteria:

- Every widget follows the shared system while retaining meaningful individual states.
- Colours carry the same meaning across widgets.
- No widget becomes visually dominant without an active reason.

## Phase 7: Popup Redesign

- [x] Create or adapt a popup-surface component related to `WidgetIsland`.
- [x] Use a more opaque background than top-bar islands.
- [x] Apply the shared border, radius, typography, and spacing tokens.
- [x] Visually connect each popup to its originating island.
- [x] Restyle the audio popup.
- [x] Restyle the media popup.
- [x] Restyle the notification centre and notification cards.
- [x] Restyle the power menu.
- [x] Add active-island state while each popup is open.
- [x] Verify popup placement and clipping on all monitors.

Acceptance criteria:

- Popups clearly belong to the same interface as the bar.
- Dense content remains more opaque and readable than the bar islands.
- Popup opening and closing produces consistent state feedback.

## Phase 8: Geometry Refinement

- [x] Review the initial 5px rounded rectangles after all widgets are wrapped.
- [x] Prototype a restrained clipped-corner treatment on one island.
- [x] Compare ordinary and clipped geometry at actual bar size.
- [x] If adopted, centralize the shape so every island uses the same corner language.
- [x] Add the optional short lower-left accent line.
- [x] Avoid decorative geometry that reduces content or click space.

Acceptance criteria:

- The silhouette feels technical without becoming ornate.
- Geometry remains consistent across islands and popups.
- The design still reads clearly at a glance.

## Phase 9: Motion and Performance Pass

- [x] Standardize all hover and state-transition durations.
- [x] Standardize easing curves.
- [x] Test rapid workspace switching and interrupted animations.
- [x] Test hover transitions while the visualizer is active.
- [x] Limit notification attention animation to one or two cycles.
- [x] Remove any animation that does not communicate a state change.
- [x] Investigate render-thread animators for any remaining visibly uneven motion.
- [x] Check CPU and GPU impact under normal use.

Acceptance criteria:

- Motion feels smooth and related across the interface.
- Rapid interactions do not produce jumps, stale states, or overlapping animations.
- The bar remains efficient during audio playback and notifications.

## Phase 10: Accessibility and Resilience

- [x] Check text and icon contrast over worst-case bright backgrounds.
- [x] Verify all click targets remain practical after visual tightening.
- [x] Confirm meaning is not conveyed by colour alone where ambiguity matters.
- [x] Test missing media players and disconnected audio devices.
- [x] Test PipeWire starting after Quickshell.
- [x] Test notification objects disappearing while the centre is open.
- [ ] Test monitor connect, disconnect, rotation, and scale changes. (Rotated dual-monitor reload verified; physical hotplug remains manual.)
- [x] Test configuration reload while popups are open.

Acceptance criteria:

- Common service and lifecycle failures recover without restarting the session.
- The interface remains readable and operable across supported monitor layouts.
- No new recurring runtime warnings originate from redesigned components.

## Phase 11: Final Review

- [x] Capture final screenshots matching the baseline scenarios.
- [x] Compare the implementation against every principle in `DESIGN.md`.
- [x] Review the bar over several bright, dark, and visually busy backgrounds.
- [x] Remove unused theme tokens and abandoned styling experiments.
- [x] Run formatting and QML validation checks.
- [x] Review the final diff for unrelated changes.
- [x] Update `DESIGN.md` where implementation decisions refined the original direction.
- [x] Mark completed tasks and document intentionally deferred ideas.

Acceptance criteria:

- The implementation matches the design direction and guardrails.
- Behavioural regressions have been ruled out.
- Documentation reflects the shipped interface rather than an outdated proposal.

## Deferred Ideas

These should be considered only after the initial design has been used and evaluated:

- [ ] More elaborate chamfered or asymmetric island shapes.
- [ ] Very subtle active-edge glow.
- [ ] Context-dependent visualizer gradients.
- [ ] Alternate compact layout for narrow displays.
- [ ] User-selectable opacity or blur presets.
- [ ] A low-motion accessibility option.

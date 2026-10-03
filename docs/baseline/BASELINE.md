# Phase 0 Baseline

Captured on 2026-09-13 before the floating-island redesign. This document distinguishes existing behaviour and warnings from changes introduced during the redesign.

## Screenshots

- [DP-1 full display](bar-dp1.png)
- [DP-1 bar detail](bar-detail.png)
- [DP-1 right-side detail](bar-right-detail.png)
- [DP-3 full display](bar-dp3.png)
- [Notification centre](notification-center.png)

The notification-centre capture is an empty-state baseline. The audio popup did not create a valid popup surface when its visibility was temporarily forced during a hot reload, so no misleading screenshot was retained. The media popup could not be captured because no Spotify MPRIS player was available. The power menu could not be captured because `PowerWidget` is not mounted in `TopBar`. These states should be captured when naturally available during their respective redesign phases.

All temporary popup visibility changes were reverted after capture.

## Current Bar Composition

The current `TopBar` is 40px high with 14px left and right margins and 10px layout spacing. From left to right it contains:

1. Workspace tracker.
2. Audio visualizer.
3. Flexible spacer.
4. Spotify media widget, when available.
5. Flexible spacer.
6. Notification indicator.
7. Volume controls.
8. Split clock and date.

`PowerWidget` and `WindowTitleWidget` exist in the repository but are not currently mounted in the bar.

The bar uses one opaque `Theme.background` surface across its full width. Widgets do not currently have independent background containers or hover surfaces.

## Current Widget Behaviour

### Workspaces

- Shows at least workspaces 1–5.
- Extends through the active workspace when workspaces 6–10 are selected.
- Remains extended through the highest occupied workspace from 6–10.
- Uses named mappings for workspaces 1–5 and numeric names for 6–10.
- Active workspace has a filled cyan dot with animated movement and a directional trailing stretch.
- Occupied inactive workspaces use a blue outline; empty workspaces use a subdued outline.
- Left-clicking a visible dot focuses that workspace through Hyprland's Lua dispatcher.

### Audio visualizer

- Starts `cava` with `config/cava.conf` and displays 32 bars at 60fps.
- Parses semicolon-delimited ASCII values from standard output.
- Retries `cava` after two seconds if it exits, covering the PipeWire startup race.
- Has no direct pointer interaction.

### Media

- Searches specifically for a Spotify MPRIS player.
- Is hidden when Spotify is unavailable.
- Displays artist and track title when available.
- Left click toggles the player popup.
- Right click toggles play/pause.
- Popup contains album art, metadata, progress, transport controls, and volume.

### Notifications

- Left click toggles the notification centre.
- Opening the centre resets the unread counter and hides transient toasts.
- Right click toggles do-not-disturb and hides toasts when enabling it.
- New notifications are tracked and timestamped.
- Toasts are suppressed while do-not-disturb is active.
- Clicking a notification attempts to focus its existing application, then launches it if necessary.
- Individual notifications can be dismissed; the centre can clear all notifications.

### Volume

- Displays microphone state, speaker state, and output volume percentage.
- Left click on the overall widget toggles the audio popup.
- Right click on the microphone toggles input mute.
- Right click on the speaker area toggles output mute.
- Scrolling over the speaker area changes output volume in 2% steps.
- Popup exposes output/input volume, mute state, device selection, and application streams.

### Clock

- Displays large 24-hour time with a stacked uppercase weekday and month/day.
- Uses `RobotoMono Nerd Font`.
- Has no pointer interaction.

### Power

- Component exists and toggles a placeholder power menu when clicked.
- It is not currently included in `TopBar`.

## Existing Runtime Warnings

The following warnings predate the redesign and should not be attributed to island styling unless their frequency or behaviour changes:

- `PlayerPopup`: setting `height` and `width` is deprecated; `implicitHeight` and `implicitWidth` are recommended.
- `PlayerProgressControl`: `Connections.onTrackChanged` does not match a signal on the current target.
- `PlayerProgressControl`: undefined values are assigned to `QObject*` and `bool` properties when no player is present.
- `PlayerVolumeControl`: an undefined value is assigned to a `bool` property when no player is present.
- `AudioStreamRow`: repeated attempts to read `muted` and `volume` from a null audio object.

Earlier editor-language-server parse messages were transient while files were being edited and are not present in the successfully loaded configuration. Earlier Hyprland workspace dispatch errors were resolved by switching to the Lua `hl.dsp.focus` form.

## Hyprland Layer and Blur Target

The live bar surface reports:

- Namespace: `quickshell`
- Layer: overlay (layer 2)
- Geometry on DP-1: `2560x40` at `0,0`
- Process: the active Quickshell instance

Additional Quickshell surfaces, including concave corners, notification centre, and toast layer, use the same `quickshell` namespace. A broad namespace blur rule will therefore affect popups and auxiliary surfaces as well as the bar. Blur rules should be tested carefully; a more specific application/window strategy may be required if different blur strengths are desired.

## Monitor Baseline

### DP-1

- Logical geometry: 2560x1440 at `0,0`.
- Scale: 1.
- Transform: normal (`0`).
- Refresh rate: approximately 165Hz.
- Quickshell bar present at the top edge.
- 40px top reservation reported by Hyprland.

### DP-3

- Physical mode: 2560x1440 at approximately 165Hz.
- Logical transformed geometry: 1440x2560 at `2560,-820`.
- Scale: 1.
- Transform: rotated (`3`).
- No Quickshell layer surface is currently present.
- No reserved top-bar area is reported.

The current configuration therefore behaves as a single-monitor bar on DP-1, not a replicated multi-monitor bar. Redesign verification on DP-3 means confirming that the absence of a bar remains intentional or explicitly deciding to add one; it should not be assumed that `TopBar` currently renders on every screen.

## Phase 0 Conclusions

- `quickshell` is the compositor namespace relevant to blur.
- Popup and auxiliary windows share that namespace, which affects blur-rule granularity.
- The initial island pass must preserve a fixed 40px outer bar height.
- The redesign must account for several pre-existing null-state warnings in audio and media components.
- DP-1 is the only current bar target; DP-3 provides a rotated-monitor regression case if multi-monitor support is expanded later.

# Phase 8: Geometry Refinement

Phase 8 replaces the initial conventional rounded shells with a restrained technical silhouette.

## Decision

A 5px top-right and bottom-left corner cut was prototyped on the workspace island while the neighbouring visualizer retained its rounded rectangle. At the bar's actual 40px height, the cut is legible without reading as an ornamental HUD bracket, so the treatment was adopted.

The asymmetric cuts add direction and a spacecraft-interface character while preserving the full rectangular layout and pointer area. Content padding and click targets are unchanged.

## Implementation

- Added `components/TechnicalSurface.qml`, backed by a single antialiased `ShapePath`.
- Centralized the cut size as `Theme.surfaceCutSize`.
- `WidgetIsland` now uses the technical surface for every top-bar island.
- `PopupSurface` uses the same silhouette, keeping islands and popup shells consistent.
- Fill and outline transitions remain animated through the shared hover timing token.
- Internal controls retain small rounded corners, distinguishing controls from outer containers.
- The existing short lower-left semantic accent line aligns with the bottom-left cut and remains visible only for active, attention, critical, or keyboard-focus states.

## Validation

- Compared the prototype and adopted geometry at native bar dimensions.
- Confirmed that implicit sizing, padding, dynamic workspace width, and click areas are unchanged.
- Quickshell reloads successfully with the shared shape active across all islands.
- `git diff --check` passes.

## Captures

- `phase8-workspace-prototype.png`: clipped workspace island beside rounded islands.
- `phase8-technical-geometry.png`: adopted geometry across the complete bar.

# Quickshell Bar Design Direction

## Vision

The bar should feel like a clean, semi-minimal spacecraft interface inspired by the visual language of *The Expanse*. The goal is not to reproduce a specific screen from the show, but to evoke a practical, low-light control system: restrained geometry, clear state communication, muted colours, translucent materials, and purposeful motion.

The interface should remain comfortable for daily use. Readability and hierarchy take precedence over decorative HUD effects.

## Principles

- Keep the desktop visible through a low-opacity, continuously blurred top-level glass strip.
- Give each logical widget its own floating translucent island.
- Group related controls rather than boxing every individual glyph.
- Communicate state primarily through borders, short accent marks, and subtle surface changes.
- Reserve saturated colour for information with meaning.
- Use animation to clarify transitions, not as ambient decoration.
- Maintain strong contrast and legibility over varied desktop content.

## Visual Language

### Surfaces

The panel uses a low-opacity neutral surface to establish a continuous compositor-blurred glass field. Widgets sit on denser dark translucent surfaces above it. Islands should feel visually separate from both the strip and desktop without becoming opaque blocks.

Popups contain more information than bar widgets, so they should use a more opaque version of the same surface treatment.

### Geometry

Shipped island geometry:

- Restrained 5px cuts on the top-right and bottom-left corners.
- Fine 1px border.
- Consistent horizontal and vertical padding.
- Compact gaps between neighbouring islands.
- A short lower-left accent line for active and semantic states.

Uniform pill shapes are avoided. The clipped silhouette is centralized in `TechnicalSurface.qml` and shared by islands and popup shells. Internal controls retain small rounded corners so controls remain distinct from their containers. The shape changes only the rendered surface; rectangular content and pointer bounds are preserved.

### Typography

- Primary text family: `Protomolecule`.
- Interface symbols explicitly use `RobotoMono Nerd Font`.
- Use weight and colour to establish hierarchy rather than many font sizes.
- Uppercase labels are appropriate for compact metadata and system states.
- Avoid excessive tracking on normal body text; modest tracking is suitable for short labels.

## Colour System

Starting palette values are provisional and should be tuned against the live blurred desktop.

```qml
background:        "#00000000"

island:            "#C8141820"
islandHover:       "#DC1A222C"
islandActive:      "#DC1B2933"

border:            "#4D71808C"
borderHover:       "#807FA9B8"

text:              "#E6EDF1"
textMuted:         "#AEBAC2"

accentCyan:        "#46C7D5"
accentBlue:        "#6699B8"
accentAmber:       "#D69A4A"
accentRed:         "#C85C5C"
```

### Semantic use

- **Cyan:** current selection, active controls, and ordinary emphasis.
- **Blue:** occupied or secondary-active states.
- **Amber:** attention, pending notifications, and non-critical warnings.
- **Red:** destructive actions and genuinely critical states only.
- **Muted text:** supporting metadata and inactive information.

Large saturated fills should generally be avoided. Prefer a coloured border, underline, edge marker, or small glyph.

## Island Component

A reusable `WidgetIsland` component should become the common container for top-bar widgets. It should provide:

- Translucent background surface.
- Fine border.
- Standard padding and corner geometry.
- Hover transition.
- Optional active, warning, urgent, and disabled states.
- Optional accent edge or corner marker.
- A content slot that does not dictate the widget's internal layout.

The implemented top-bar grouping is:

```text
[ workspaces ] [ visualizer ]       [ media ]       [ notifications ] [ volume ] [ clock ]
```

Media metadata and transport controls should remain one logical island. Volume-related controls should remain grouped. Popup panels are extensions of their originating island, not unrelated visual systems.

## Interaction States

| State | Surface | Border/accent | Motion |
| --- | --- | --- | --- |
| Default | Dark translucent | Subdued blue-grey | None |
| Hover | Slightly brighter | Brighter blue-grey | 150–200ms fade |
| Active/open | Subtle cyan tint | Cyan border or edge mark | 180–220ms transition |
| Attention | Default or slightly raised | Amber edge mark | One finite transition |
| Muted/disabled | Lower contrast | Muted amber or blue-grey | None |
| Critical | Slight red tint | Red edge or border | Restrained pulse if required |

Hover feedback should be visible but quiet. Opening a popup may strengthen the island border and surface until the popup closes.

## Blur and Transparency

Quickshell supplies transparent and translucent surfaces; Hyprland performs the background blur. The intended visual stack is:

```text
desktop
  -> compositor blur
    -> translucent island surface
      -> border and accent
        -> widget content
```

Blur should be moderate and should not compromise text contrast. A small amount of compositor noise may help prevent banding, but heavy frosted-glass effects would conflict with the utilitarian direction.

Top-bar islands can be relatively transparent. Audio, notification, media, and power popups should be more opaque because they contain denser information.

## Motion

- Hover and colour transitions: approximately 150–220ms.
- Positional transitions: approximately 220–300ms.
- Preferred easing: `InOutSine` or a restrained cubic curve.
- Reversals should remain smooth when state changes rapidly.
- Avoid continuous decorative animation.
- The audio visualizer provides the bar's ambient movement; other elements should remain calm.

The animated workspace indicator is the reference for purposeful motion. Similar transitions should share its timing and character where appropriate.

## Widget-Specific Ideas

### Workspaces

- Keep the current circular tracker and moving active indicator.
- Active workspace uses cyan.
- Occupied inactive workspaces use blue outlines.
- Empty workspaces use subdued outlines.
- The containing island may gain a subtle active accent during workspace transitions.

### Audio visualizer

- Keep it visually lightweight.
- Use a single muted neutral steel-grey tone with only a small brightness response at higher levels.
- Avoid glow strong enough to compete with status indicators.

### Media

- Treat metadata and controls as one island.
- Use muted metadata with high-contrast primary track information.
- Playback state may control a small accent marker rather than recolouring the whole surface.

### Notifications

- Default state remains subdued.
- Unread notifications use amber.
- Do-not-disturb uses a muted, low-contrast state.
- Urgent notifications may use red, but only when their urgency is explicit.

### Volume

- Normal state uses neutral or cyan accents.
- Muted state uses amber rather than red.
- The popup should use a denser, more opaque island surface.

### Clock

- Retain the split time and stacked date treatment.
- Time remains the primary high-contrast element.
- Day/date remains secondary, with cyan used sparingly.

## Implementation Sequence

1. Expand `Theme.qml` with semantic surface, border, accent, and state tokens.
2. Make the top-level panel visually transparent.
3. Create the reusable `WidgetIsland` component.
4. Wrap existing top-bar widgets without changing their behaviour.
5. Add consistent hover, active, notification, and muted states.
6. Configure and tune Hyprland blur for the Quickshell layer surface.
7. Refine geometry, potentially adding restrained clipped corners or accent edges.
8. Bring popups into the same design system with increased opacity.
9. Review the complete bar over both bright and dark desktop content.

## Guardrails

- Do not sacrifice readability for translucency.
- Do not use glow on every active element.
- Do not animate elements without communicating a state change.
- Do not introduce many unrelated accent colours.
- Do not over-segment related controls into separate boxes.
- Do not let decorative corner treatments reduce usable click targets.
- Keep all state colours semantic and consistent across widgets.

## Shipped Outcome

The implemented bar uses a low-opacity continuous glass panel, denser dark translucent islands, moderate Hyprland blur, fine neutral-grey borders, asymmetric 5px corner cuts, and restrained semantic accents. Popup panels use a denser version of the same surface and geometry. Motion is centralized by role and limited to state communication, except for the audio-driven visualizer.

The current shell intentionally creates one bar on DP-1. The rotated DP-3 monitor remains a bar-free secondary display. `PowerWidget` also remains unmounted, and its popup remains an explicitly non-functional visual placeholder rather than exposing unreviewed destructive commands.

Muted text and base-island opacity were raised during accessibility review to remain readable over bright desktop content. State is reinforced through shape, fill, outline weight, glyph changes, or labels where colour alone would be ambiguous.

# Shell Design Direction

## Purpose

This shell should feel like a cohesive interface embedded into the desktop environment, not a collection of unrelated widgets placed over it. Its visual language draws from cinematic science-fiction interfaces, modern glass materials, and precision instrumentation, while remaining comfortable and practical for everyday use.

This document is a shared design reference rather than a fixed specification. It describes the character and principles that should guide future decisions without prescribing exact dimensions, colours, components, or implementation techniques. Individual features may depart from these ideas when usability, technical constraints, or a stronger visual result justify doing so.

## Character

The shell should feel:

- Technical, precise, and intentional.
- Futuristic without becoming theatrical or ornamental.
- Atmospheric without overwhelming the desktop.
- Dark and translucent while remaining clear and readable.
- Expressive with colour where it adds identity, meaning, or focus.
- Calm at rest and responsive during interaction.
- Spacious enough that applications do not feel enclosed or crowded.

The result should suggest a designed system with its own identity, but not a literal recreation of an interface from a film, game, or existing desktop environment.

## Composition and Hierarchy

The desktop and its applications remain the primary workspace. The shell should establish a recognisable presence around that workspace without competing with it or unnecessarily reducing its visual space.

Large surfaces establish atmosphere and structure. Smaller surfaces organize related information and controls. Elements that belong together should read as coherent modules, while unrelated functions should retain enough separation to be understood at a glance.

Hierarchy should come from composition, contrast, density, and motion rather than simply making important elements larger or more saturated. Empty space is an active part of that hierarchy. It creates rhythm, prevents the interface from feeling crowded, and allows important states to stand out when they appear.

The shell may visually connect with display edges, but it should avoid enclosing the entire workspace unless that enclosure serves a clear purpose and has sufficient breathing room.

## Material and Depth

Transparency should create a sense of depth and environmental continuity rather than merely making surfaces faint. Glass-like materials should respond visually to the desktop beneath them while preserving enough density for their contents to remain legible.

Surfaces can form a hierarchy of material:

- Environmental surfaces establish the shell's presence.
- Functional modules organize compact information and controls.
- Expanded panels provide greater density for detailed content.

Borders, highlights, tint, blur, and shadow may suggest material thickness, but these effects should remain subordinate to the interface itself. Where surfaces are intended to be continuous, they should read as one material rather than a collection of visibly overlapping effects.

Information-heavy surfaces may become more opaque than persistent shell elements. Readability takes priority over preserving the same degree of transparency everywhere.

## Shape and Geometry

Prefer simple, confident silhouettes with clear relationships between them. Repeated geometry should establish family resemblance across the shell without forcing every component into an identical container.

Rounded forms can soften dense technical information, while straighter edges, cuts, or extensions can add direction and precision. Such details should have a structural purpose: connecting surfaces, indicating origin, supporting hierarchy, or clarifying interaction. Decorative geometry should not compromise alignment, usable space, or practical hit targets.

The visible shape of a control may be compact, but its interaction area should remain forgiving. Geometry should adapt gracefully to changing content rather than becoming fragile when labels, values, or service states change.

## Colour and Light

The visual foundation should remain dark, cool, and translucent. Luminous accents can provide energy and character, particularly against the restrained base material.

Colour should be deliberate. It may communicate state, establish focus, distinguish categories, or contribute to the shell's identity. Repeated colours should develop consistent meanings where practical, especially for warning, destructive, muted, and selected states. This consistency should not become so rigid that every expressive use of colour is prohibited.

Not every interactive element should demand attention at once. Bright colour, glow, and high contrast are most effective when quieter elements surround them. Critical and destructive states must remain unmistakable even when the broader palette is expressive.

## Typography and Information

Typography should feel precise and contemporary while remaining easy to scan. Primary information and supporting metadata need clear separation through weight, contrast, spacing, or scale.

Labels should be concise, and technical styling should serve the information rather than turn every surface into a terminal display. Icons should remain recognisable before they become stylistically distinctive. Dense information should reveal a clear reading order instead of relying on the user to decode an undifferentiated block.

## Motion and Expansion

The shell should be calm at rest but feel cohesive and physical when it changes. Motion is especially important when an element expands, reveals more information, or transitions from a compact control into a larger panel.

Expanded content should feel connected to the control or surface that produced it. A notification centre, media panel, system menu, or similar view should not appear as an unrelated window abruptly placed nearby. Its transition should communicate origin, continuity, and the relationship between the compact and expanded states.

This principle does not prescribe a particular animation. A panel might extend from an existing surface, slide along a shared edge, unfold, fade through an intermediate state, or use another approach. The appropriate solution depends on the content and surrounding composition. What matters is that expansion feels like a transformation within the shell rather than the appearance of a separate application.

Transitions should be smooth, responsive, and reversible. They should clarify changes in state and spatial relationship without making routine actions feel slow. Ambient motion should be limited to information that is genuinely alive; the rest of the shell should not move simply to attract attention.

## Interaction and Resilience

Hover, focus, pressed, open, muted, unavailable, and attention states should be perceptible without requiring excessive visual change. Feedback should arrive quickly and remain consistent with the material and motion language of the shell.

The interface should remain understandable when data or services are temporarily unavailable. Missing content should not collapse the composition unpredictably, and recovery should feel natural when the information returns.

Performance is part of the interaction design. Blur, animation, and other effects should remain smooth enough that they strengthen the illusion of a cohesive physical interface rather than exposing its implementation.

## Adaptability

The design should tolerate bright, dark, and visually busy backgrounds. Components should remain coherent across different content lengths, data states, monitors, and available space.

Future work should consider accessibility, reduced-motion preferences, contrast, and alternative input methods as part of the system rather than as unrelated additions. Adaptation may change the presentation, but it should preserve the shell's hierarchy and character.

## Anti-Goals

The shell should not become:

- A maximalist HUD covering every edge of the display.
- A generic collection of interchangeable rounded cards.
- A literal imitation of a fictional interface.
- A showcase for blur, glow, or animation at the expense of content.
- So minimal that state, hierarchy, and personality disappear.
- So rigidly standardized that useful experimentation becomes difficult.
- Dependent on ideal data, services, or background imagery to remain usable.

## Using This Document

These principles are a baseline for design judgment, discussion, and review. They are not absolute rules. When a component requires a different solution, the decision should be evaluated by how well it supports the wider experience: clarity, cohesion, responsiveness, atmosphere, and room for the desktop to breathe.

As the shell develops, this document should evolve with its overall design direction. It should describe the system we are intentionally building, not preserve decisions simply because they were made in the past.

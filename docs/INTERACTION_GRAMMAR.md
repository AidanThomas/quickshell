# Shell Interaction Grammar

## Status and purpose

This document defines the baseline interaction vocabulary for the shell. It gives
compact controls a consistent meaning across pointer, touchpad, and keyboard input
without requiring every widget to share the same layout or visual identity.

The grammar is a design contract rather than an immutable component API. A widget
may depart from it when its task requires a stronger interaction, but the exception
should remain understandable, discoverable, and accessible through every supported
input path.

`DESIGN.md` describes the shell's overall character. `BAR_COMPOSITION.md` decides
where capabilities originate and when they occupy space. This document decides how
people operate those capabilities and how their states should be communicated.

## Core principles

1. The same gesture should have the same broad meaning wherever practical.
2. A primary action must not require prior knowledge of a hidden gesture.
3. Secondary click, scrolling, and shortcuts may accelerate an action, but must not
   be its only usable route.
4. Feedback should explain what changed without overwhelming the content.
5. Pointer hover may add information, but must not be required to understand or use
   a control.
6. Keyboard focus, semantic status, and open state are distinct and may coexist.
7. Compact controls may retain distinct silhouettes and internal controls while
   following the same activation, focus, and dismissal expectations.
8. Unavailable services should produce an understandable state rather than a dead
   or misleading control.

## Action vocabulary

### Primary activation

Primary activation performs the action most strongly implied by the control.

- On an expandable island, primary activation opens its primary surface. Activating
  the origin again closes that surface.
- On a direct control, primary activation performs the visible action, such as
  selecting a workspace, toggling play, or toggling mute.
- On an item inside an expanded surface, primary activation selects or invokes that
  item.
- `Enter` and `Space` invoke the same primary action when the control has keyboard
  focus.

An island that contains direct controls as well as an expanded surface must give
those controls unambiguous hit targets. Primary activation on otherwise unclaimed
space opens the surface; activating a child control performs only that child's
action.

### Secondary activation

Secondary activation provides an optional shortcut to a closely related action. It
must not be the only route to important or commonly needed functionality.

Appropriate examples include toggling media playback from the media origin or
temporarily accelerating access to a mute action that is also visible in the audio
surface. Destructive, difficult-to-reverse, configuration, and safety-sensitive
actions must not be assigned to an unexplained secondary activation.

Where secondary activation exists, a tooltip or another nearby explanation should
name it. On platforms or input devices without secondary activation, the same
action remains available through the expanded surface or a visible direct control.

### Scrolling

Scrolling over a control adjusts the value most clearly represented by that
control. It must never cause an unrelated or surprising state change.

- Audio scroll adjusts output volume in small, bounded steps.
- Workspace scroll may navigate adjacent workspaces if later adopted consistently.
- Scrolling ordinary islands with no natural adjustable value passes through or has
  no effect.

Scroll adjustment must have immediate visual feedback and an equivalent keyboard or
expanded-surface control. A tooltip should disclose the behavior where the control
does not visibly resemble an adjustable value. High-resolution touchpad deltas
should be accumulated or normalized so small movements remain controlled.

### Hover

Hover confirms interactivity and may reveal a concise label or usage hint. It does
not reveal the only instance of a control, change layout, or trigger an action.

Hover feedback should be restrained and immediate. Persistent bar controls remain
positionally stable: hover must not translate, lift, scale, resize, or otherwise
move an island or its contents. Surface, outline, light, and similarly non-spatial
changes can provide responsive feedback without disturbing the geometry from which
an expanded surface flows.

Hover does not open an interactive expanded surface. Opening remains an intentional
primary activation so moving across the bar cannot unexpectedly change shell state
or reveal a surface that must then be dismissed. A lightweight, non-interactive
preview may appear on hover when it adds useful context, but it must not accept
focus, replace the expanded surface, or make an action available only through the
preview.

A tooltip appears only after a short delay, remains stable while the pointer moves
within the same target, and disappears promptly when the target is left, activated,
or obscured by an expanded surface.

Ambient and read-only elements should not receive interactive hover treatment.

### Keyboard navigation

Interactive bar origins and their direct child controls participate in a predictable
focus order matching their visual order. Read-only and ambient elements do not take
focus.

- `Tab` and `Shift+Tab` move between focusable controls.
- Arrow keys may move within a composite control when that relationship is clear,
  such as workspace choices, a menu, or a slider.
- `Enter` and `Space` perform primary activation.
- `Escape` closes the active expanded surface.
- Standard arrow, page, home, and end behavior should be retained for sliders,
  lists, and selection controls where supported.

Opening a surface moves focus into it when immediate interaction is expected.
Closing it restores focus to the originating control when that control still
exists. Focus must never become trapped in a closed, hidden, or unavailable
surface.

Global shortcuts may open a shell feature directly. The resulting focus and open
state should be the same as if the feature had been opened through its visible
origin.

## Expandable controls

All expandable origins follow the same lifecycle contract:

1. Primary activation requests opening.
2. The origin enters its open state for the full lifetime of the surface.
3. Focus enters the surface when appropriate.
4. Re-activating the origin, pressing `Escape`, or activating outside the surface
   requests closing.
5. Focus returns to the origin after keyboard-initiated dismissal.

A non-modal surface dismisses when the user activates outside both it and its
origin. The pointer release belonging to the activation that opened the surface
must not immediately dismiss it. Moving focus between the origin and its surface is
not an outside interaction.

Opening one surface normally closes another surface in the same shell scope. A
transient notification may coexist with an unrelated expanded surface, but should
not steal keyboard focus from it.

Confirmation and destructive flows may require an explicit choice rather than
click-away dismissal. Those flows should clearly communicate that they are modal.

The reusable cross-window lifecycle, geometry, connector, and transition machinery
belongs to the shared expansion work. This grammar defines the observable behavior
that machinery must provide.

## Interaction and semantic states

States are grouped into independent dimensions. A control may be focused and open,
or critical and unavailable, without forcing one state to erase the other.

### Interaction states

| State | Meaning | Expected feedback |
| --- | --- | --- |
| Default | Available and at rest. | Normal surface, content, and outline treatment. |
| Hover | A pointing device is over an interactive target. | Modest non-spatial surface, outline, or light response; no movement or layout change. |
| Pressed | Primary activation is being held. | Immediate, reversible acknowledgement distinct from hover. |
| Focused | The control has visible keyboard focus. | Persistent high-contrast focus indicator independent of hover. |
| Open | The control's expanded surface is active. | Persistent active treatment and a visible relationship to the surface. |

Visible keyboard focus should follow keyboard navigation rather than every pointer
click. An open indicator does not substitute for a focus indicator.

### Availability states

| State | Meaning | Expected behavior |
| --- | --- | --- |
| Ready | The promised action or data is available. | Normal interaction. |
| Loading | Data or a service is expected but not ready. | Stable geometry, restrained progress feedback, and no false value. |
| Unavailable | The promised capability cannot currently be used. | Disabled unsafe actions, an explicit fallback or explanation, and no misleading activation. |

Loading feedback should be used only for a perceptible wait, not flashed during
routine updates. Unavailable controls may remain focusable when focusing them is
needed to expose an explanation or recovery action. Merely lowering opacity is not
enough when the reason matters.

### Semantic states

| State | Meaning | Expected feedback |
| --- | --- | --- |
| Muted | Output, input, or notifications are intentionally suppressed. | Clear icon or label change; reduced prominence may support but not replace it. |
| Attention | New or exceptional information deserves awareness but is not urgent. | Restrained accent and, where useful, a count or concise status. |
| Critical | Immediate awareness or action may be required. | Unmistakable semantic color plus icon, label, or other non-color cue. |

Semantic states do not automatically make an element interactive and must not alter
the meaning of its primary action. Critical state outranks routine attention in
accent and emphasis, while visible focus remains distinguishable from both.

Muted is not synonymous with disabled: a muted control remains available and its
state should be reversible. Similarly, unavailable does not necessarily mean
critical; severity and availability are separate concerns.

## Discoverability

### Visible affordances

A visible affordance is preferred when an action is important, frequently used,
destructive, difficult to reverse, or central to understanding the control. Compact
space alone is not a reason to hide such an action behind a gesture.

Direct controls are appropriate when their targets remain visually distinct and
large enough to activate reliably. Expanded surfaces are preferred for detailed
selection, configuration, history, and infrequent actions.

### Tooltips and labels

Tooltips should be provided for:

- icon-only controls whose meaning is not universally clear;
- expandable origins whose content does not make expansion evident;
- unavailable controls that need a short explanation;
- supported shortcuts, scrolling, or secondary activation;
- truncated text when the full value is useful.

A tooltip starts with the control's name or primary action. An optional second
clause may disclose one useful accelerator, for example `Audio — scroll to adjust
volume`. Tooltips should not contain essential instructions, long status messages,
or several competing shortcuts.

Hover labels must not resize the persistent bar or displace neighbouring content.
Keyboard focus should expose the same label or description where practical.

## Input expectations

| Capability | Pointer | Touchpad | Keyboard |
| --- | --- | --- | --- |
| Primary activation | Primary click | Primary click/tap | `Enter` or `Space` |
| Secondary accelerator | Secondary click | Secondary click/tap where configured | Visible control or documented shortcut |
| Value adjustment | Wheel | Normalized two-finger scroll | Arrow keys or expanded control |
| Move between origins | Pointer movement | Pointer movement | `Tab` / `Shift+Tab` |
| Move within a composite | Pointer movement | Pointer movement | Arrow keys where appropriate |
| Dismiss surface | Activate outside | Activate outside | `Escape` |

Touchpad use must not depend on hover being available before activation. A future
touch interface should reuse primary activation and visible controls, while actions
currently accelerated by hover, secondary click, or scrolling retain another
route.

Hit targets may be larger than their visible geometry. Overlapping targets must not
make the result depend on event propagation details that users cannot perceive.

## Motion and reduced motion

Interaction feedback should prioritize response over flourish. Pressed feedback is
immediate; hover and focus transitions are brief and non-spatial within the
persistent bar; opening and closing motion should communicate origin and spatial
relationship from stable bar geometry.

When reduced motion is enabled:

- remove lift, scale, travel, spring, and overshoot effects;
- replace spatial expansion with immediate state changes or brief fades;
- retain focus, open, attention, critical, and progress feedback;
- stop non-essential ambient motion;
- do not delay interaction to preserve an animation timeline.

Reduced motion must preserve the same lifecycle and final states. Detailed motion
roles and implementation tokens belong to the shell motion work; expansion motion
belongs to the shared expansion mechanism.

## Widget application

This table applies the grammar to known and planned bar capabilities. It establishes
behavioral expectations, not final widget layouts.

| Capability | Primary activation | Direct or accelerated actions | Expanded destination |
| --- | --- | --- | --- |
| Workspaces | Select the represented workspace. | Arrow-key navigation within the workspace group; scrolling may navigate adjacent workspaces only if adopted and disclosed. | Future workspace/window overview from its own explicit origin. |
| Launcher | Open or close search. | Global shortcut invokes the same state and focus destination. | Application, window, command, and action search. |
| Focused application | Open application or window actions if provided; otherwise remain non-interactive. | No hidden action while it is only contextual text. | Future window switching or application actions. |
| Media | Open or close media details. | Visible play/pause in the expanded surface; secondary activation may accelerate play/pause when disclosed. | Metadata, seeking, transport, player selection, and supported volume. |
| Notifications | Open or close notification history. | DND remains visibly controllable in the surface; secondary activation may accelerate it when disclosed. | Notification history, grouping, actions, and DND. |
| Audio | Open or close audio controls when activating unclaimed island space. | Explicit microphone and speaker mute targets; scrolling output adjusts volume with visible feedback. | Volume, devices, and application streams. |
| Clock | Open or close calendar/time details when that surface exists. | No hidden secondary action by default. | Calendar and time surface. |
| System status | Open or close system controls. | Exceptional compact states may expose a clearly targeted safe action, but do not change the origin's general meaning. | Connectivity, privacy, tray, settings routes, and session controls. |
| Ambient visualization | No action unless a destination is intentionally assigned. | No hover or focus treatment while read-only. | None by default. |

## Exceptions and review

An exception should be evaluated against these questions:

1. Is the action still discoverable without knowing the gesture in advance?
2. Is there an equivalent keyboard path?
3. Does the result remain predictable when hover or secondary click is unavailable?
4. Are focus, open, availability, and semantic states still distinguishable?
5. Does the exception clarify the widget's task rather than merely save space?

If an exception repeatedly appears across widgets, it should become part of this
grammar or a shared component rather than remain duplicated local behavior.

## Prototype and validation contract

The first implementation prototype should exercise this grammar on media and audio.
Together they cover expansion, direct child controls, secondary activation,
scrolling, muted state, unavailable services, and keyboard equivalence.

The prototype exposes `quickshell:focusBar` through Hyprland's global-shortcut
protocol and `quickshell ipc call bar focus` for direct invocation. A compositor
binding may use the global shortcut as the normal keyboard entry path; the IPC
method provides the same behavior for testing and external orchestration. `Escape`
leaves bar navigation when no expanded surface is handling it.

The prototype should demonstrate:

- predictable focus order and visible keyboard focus;
- primary activation through pointer and keyboard;
- pressed, focused, open, muted, loading, and unavailable presentation;
- disclosed secondary and scroll accelerators;
- `Escape`, origin re-activation, and click-away dismissal;
- focus restoration after keyboard dismissal;
- stable behavior during rapid open and close requests;
- a state model and component API whose final states do not depend on animation.

The shell motion work remains responsible for introducing the reduced-motion
preference and validating equivalent final states once its shared motion roles and
tokens exist. This prototype must not prevent that adaptation or encode interaction
semantics solely in motion.

Later workspace, notification, clock, launcher, and system-control work should use
the same vocabulary while remaining free to develop distinct content and visual
identities.

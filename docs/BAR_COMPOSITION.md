# Bar Composition Model

## Status and purpose

This document is the working information architecture for the shell's persistent
bar. It translates the principles in `DESIGN.md` into decisions about placement,
visibility, priority, and empty states. It does not define the visual treatment,
interaction grammar, or expansion animation of individual controls.

The model is intentionally lightweight. It should be revised when prototypes or
real use reveal a stronger composition, rather than treated as a fixed inventory
of widgets.

## Content classes

Every capability should justify its compact presence using one of these classes.
The class describes when information appears, not how its component looks.

| Class | Meaning | Bar behaviour |
| --- | --- | --- |
| Persistent | Continuously useful for orientation or glanceability. | Keeps a stable place in the normal resting composition. |
| Contextual | Useful only while a relevant activity or object exists. | Appears in a reserved region without displacing unrelated persistent content. |
| Transient | Communicates a recent event or temporary change. | Appears briefly, then resolves into a quieter state or history. |
| Exceptional | Requires awareness because something is active, degraded, unsafe, or needs action. | May override the normal quiet summary, but should not permanently enlarge the bar. |
| Expansion-only | Useful on demand but not continuously glanceable. | Has no dedicated compact representation; it is reached through a related regional entry point. |
| Ambient | Represents genuinely live activity but is not required to operate the shell. | May have a permanent compositional role, but its motion and emphasis must yield before actionable information. |

Being frequently used is not, on its own, a reason for persistent display. A
capability may also have more than one class across its states: notifications are
transient on arrival, exceptional when critical, and expansion-only as history.

## Bar membership and occupancy

Choosing a widget for the bar is also a decision to give it space. A bar widget
does not appear only when its state becomes interesting: in the normal supported
layout it keeps its place and expresses ordinary, inactive, and exceptional states
within that place.

There are two reasons for an accepted widget not to occupy its usual space:

1. Its role is inherently contextual or transient and its relevant state does not
   currently exist. The media widget, for example, need not appear when there is no
   qualifying player activity.
2. The available width is below the layout's normal range and space is needed by a
   higher-priority widget. Responsive policy may then compact and eventually hide
   lower-priority widgets in a deliberate order.

This rule applies to widgets, not every capability available through them. Network,
Bluetooth, privacy, and session controls can belong to one persistent system widget
without each receiving permanent compact representation. Audio has its own
persistent widget. Capabilities within the system widget may be quiet or absent
while the widget itself continues to occupy its bar position.

## Regional contract

### Left: navigation and location

The left region answers **where am I, and where can I go?** It is the stable
navigation origin for workspaces, launching, window switching, and restrained
focused-application context.

- Workspace position is persistent.
- The launcher has its own visible compact origin, but not a large permanent search
  field. This makes the feature discoverable, supports pointer access, and gives
  its expansion a clear spatial origin.
- Focused-application identity is contextual and subordinate to workspace
  navigation. A minimal active-window title may add useful orientation and provide
  a future expansion origin, but should not grow into duplicated application chrome.
- Detailed workspace, window, and search interfaces are expansion-only.

### Centre: current activity

The centre answers **what is meaningfully active now?** It is a reserved,
monitor-centred contextual region rather than a permanently occupied widget slot.

- Controllable media is the primary known use of the region. Paused media continues
  to qualify while its player remains available to control.
- No media or other qualifying activity produces intentional empty space.
- Focused-window titles do not automatically fill the centre; ordinary focus
  context belongs on the left.
- Transient content should use the centre only when it represents current activity
  and does not compete with a more relevant activity.
- Content appearing or disappearing must not shift the left and right regions.

### Right: system condition and time

The right region answers **when is it, and does the system need me?** It combines
time, notifications, and system state without assigning every service a permanent
island.

- Time remains persistent.
- A compact audio widget retains direct microphone, speaker, and output-volume
  information.
- A separate compact system-status entry point houses connectivity, privacy,
  session, tray, and other system capabilities while keeping simultaneously
  relevant states individually legible.
- The system-status widget keeps its place in the normal layout; healthy network,
  Bluetooth, devices, and services remain quiet within it.
- Privacy use, failures, warnings, and other exceptional states become visible
  through the system summary.
- Notifications and machine state remain separate widgets because they serve
  different purposes, even though both belong to the right-side composition.
- Tray items, device selection, per-application audio, session actions, calendars,
  notification history, and detailed settings are expansion-only in normal use.

## Capability matrix

| Capability | Class in normal use | Origin | Normal compact state | When attention is justified | Expanded destination |
| --- | --- | --- | --- | --- | --- |
| Workspaces | Persistent | Left | Current position plus restrained occupancy cues | Activity or urgency on another workspace | Workspace/window overview or switcher |
| Launcher and search | Persistent origin, expansion-only content | Left | Its own visible, compact, discoverable entry point beside the wider navigation composition | No unsolicited attention state | Application, window, command, and action search |
| Focused application | Contextual | Left | Minimal active-window title without additional application chrome | Urgent application or special workspace state | Window switching or application actions, if supported |
| Media | Contextual | Centre | Current relevant player whenever it remains available to control, including while paused | State change may be transient; errors should remain restrained | Metadata, seeking, transport, player selection, supported volume |
| Audio visualization | Persistent ambient widget | Left, retaining its current residence unless composition prototypes establish a stronger placement | Keeps its place in the normal layout; motion reflects actual audio availability | Never outranks actionable or privacy state | Usually none; may route to media or audio controls |
| Notifications | Persistent widget with transient and exceptional states | Right | Keeps a quiet compact presence, including with no unread notifications | New arrival, critical content, or deliberately enabled status | Notification history, grouping, actions, and do-not-disturb |
| Audio output | Persistent audio-widget content | Right audio widget | Speaker state and output volume, matching the current widget | Muted output, missing endpoint, or meaningful device change | Primary volume, devices, and application streams |
| Audio input | Persistent audio-widget content with exceptional states | Right audio widget | Microphone state, matching the current widget | Active capture, unexpected unmute, or missing endpoint | Input level, mute, device selection, and privacy context |
| Network | Quiet system status | Right system summary | Its identity may be omitted inside the system widget while healthy, without removing the parent widget | Offline, degraded, captive, or action required | Connection selection and relevant settings |
| Bluetooth | Quiet system status | Right system summary | Hidden when healthy and inactive | Important device connection, failure, or low device battery if available | Device connection and management |
| Privacy and capture | Exceptional | Right system summary | Hidden when no capture is active | Microphone, camera, or screen capture in use | Originating application and safe controls where available |
| Other system health | Exceptional | Right system summary | Hidden while healthy | Thermal, storage, update, or degraded-service condition requiring awareness | Explanation and route to an appropriate action or setting |
| System tray | Expansion-only; exceptional item state may surface | Right system summary | No row of application icons | An item explicitly reports attention or failure | Collapsed tray/overflow with item menus and actions |
| Clock and date | Persistent | Right | Time with restrained date context | Timers or alarms only if later included intentionally | Calendar and time surface |
| Session and power | Expansion-only | Right system summary | No separate permanent power control | No attention state; availability failures belong inside the surface | Lock, logout, suspend, reboot, and power controls |

## Composition state matrix

These representative states test the model as a system. They describe information
priority, not final geometry or styling.

| Situation | Left | Centre | Right | Expected composition behaviour |
| --- | --- | --- | --- | --- |
| Resting desktop, no media | Workspaces, launcher origin, optional desktop/workspace context | Empty | Quiet notification, audio, and system widgets plus clock | Empty centre remains deliberate; side regions do not stretch into it. |
| Focused application, no media | Workspaces plus restrained application identity | Empty | Normal quiet state | Application context does not become a conventional centre title bar. |
| Media playing | Normal navigation state | Active media | Normal quiet state | Media is physically monitor-centred and may expand without moving either side. |
| Media paused | Normal navigation state | Media remains present in a quieter paused state while its player is controllable | Normal quiet state | Pause is a player state, not a reason to remove an otherwise useful control. |
| Multiple media players | Normal navigation state | Most relevant player | Normal quiet state | Player selection lives in expansion unless ambiguity requires a compact cue. |
| Notification arrives | Stable | Current activity remains stable | Toast/transient state connected to notification origin | Arrival does not reflow navigation or current activity. |
| Critical notification | Stable | Current activity remains stable unless safety requires otherwise | Clear critical state with access to content | Critical treatment overrides quiet right-side styling, not the regional layout. |
| Microphone/camera/screen capture active | Stable | Current activity remains stable | Unmistakable privacy state replaces or augments the quiet system summary | Privacy outranks routine connectivity, tray, and audio information. |
| Network or service degraded | Stable | Current activity remains stable | Each relevant status remains individually identifiable within the system composition | Simultaneous problems do not collapse into an ambiguous aggregate representation. |
| Launcher open | Navigation origin becomes active | Existing activity may quiet visually but retains its state | Stable | Expansion clearly originates from the left and may use space below multiple regions. |
| System surface open | Stable | Existing activity may quiet visually but retains its state | System origin becomes active | Detailed status, tray, audio, and session routes share one coherent surface. |
| Constrained width | Preserve navigation origin and current workspace | Compact, then hide lower-priority content according to the responsive order | Preserve clock and actionable/exceptional state; compact lower-priority status | Normal membership remains intact until widgets would compete for or overlap one another's required space; widgets then compact and hide by explicit priority rather than by whether their current state is interesting. |
| Service unavailable | Preserve usable navigation and explicit fallback where needed | Omit unavailable contextual content | Show unavailability only when it affects a promised capability or needs action | Missing data does not leave broken placeholders or collapse unrelated regions. |

## Priority and displacement rules

1. Safety, privacy, and critical states outrank routine and ambient information.
2. Navigation and time retain stable origins; contextual content must not move them.
3. The centre is independently centred on the monitor, not centred in the space
   remaining between unequal side groups.
4. Each region owns its internal composition. New capabilities attach to an
   existing regional origin unless they establish a genuinely new shell role.
5. Expansion-only capabilities do not receive a permanent island merely to make
   them reachable; their parent origin must make their availability discoverable.
6. Transient information may temporarily increase prominence, but it should settle
   into history, an appropriate parent-widget state, or absence.
7. A widget accepted into the normal bar keeps its space through ordinary state
   changes unless its role is explicitly contextual or transient.
8. Responsive reduction occurs only when available width requires it. Widgets
   compact and then hide in an explicit priority order; low current activity alone
   is not a reason to reclaim their space.
9. Ambient motion may stop under reduced motion or unavailable data without
   requiring the ambient widget itself to disappear.
10. Empty space is preserved when no contextual or transient content qualifies for
    a reserved region; it is not created by opportunistically removing normal bar
    members.
11. Simultaneous exceptional states remain individually identifiable. A shared
    state may affect several widgets, and each affected widget should respond in
    its own context rather than being replaced by one ambiguous aggregate warning.

## Responsive priority

Responsive reduction occurs in two phases. Content first compacts within its
widget; whole widgets hide only if those compact forms still compete for space.
Exceptional or critical state temporarily promotes the affected widget above its
normal position in the order.

### Compact content before hiding widgets

1. Truncate the focused-window title to a minimal application identity while
   retaining its place beside navigation.
2. Shorten media metadata, preserving recognisable identity and primary control.
3. Remove secondary clock/date text while preserving the time.
4. Remove the audio volume number while preserving microphone and speaker state.
5. Reduce workspace occupancy detail while preserving the current-workspace control.

### Hide widgets from first to last

The normal-state order is:

1. Launcher origin; its keyboard shortcut remains available.
2. Focused-application context.
3. Audio visualizer.
4. System status, but only while it has no exceptional state.
5. Notifications, but only while it has no unread, transient, or critical state.
6. Media.
7. Audio.

The clock and current-workspace control form the minimum persistent composition and
are not hidden at the supported widths. Privacy, safety, and critical states are
never discarded by this order: they displace the lowest remaining normal-state
content if necessary.

This is a semantic order. Exact minimum widths, breakpoints, and whether an
intermediate presentation is useful belong to responsive implementation work.

## Boundaries with related work

This document decides where information originates, when it is present, and what
it may displace. Related foundation work remains responsible for:

- the meaning of click, scroll, focus, hover, and keyboard actions;
- expansion lifecycle, geometry, dismissal, and focus capture;
- motion roles and reduced-motion behaviour;
- component silhouettes and visual differentiation;
- exact responsive thresholds and secondary-monitor policy.

Those efforts may expose a problem with this composition model, but should not
silently assign a new permanent bar position to a capability.

## Settled composition decisions

- The launcher has a dedicated visible origin. Keyboard invocation remains primary,
  but functionality should not be hidden from pointer users and its expanded surface
  needs somewhere legible to originate.
- Focused-application context uses a minimal active-window title. Additional detail
  must justify itself rather than accumulate into duplicated application chrome.
- Media remains in the centre for as long as a player is available to control,
  including while paused. It disappears when no controllable player remains.
- Notifications and system status are separate widgets with separate conceptual and
  interaction boundaries.
- Audio and system status are separate widgets. Audio retains direct, glanceable
  controls while connectivity, privacy, tray, session, and other system capabilities
  share the system-status origin.
- The audio visualizer earns permanent residence for its contribution to the bar's
  character, despite not needing a direct functional benefit.
- Concurrent exceptional states remain distinct. Widgets affected by a shared state
  each respond appropriately instead of being replaced by an aggregate warning.
- Responsive compaction begins when the existing presentation would take required
  space from another widget. Exact thresholds follow from widget minimum sizes and
  the priority order rather than from arbitrary monitor-width categories.
- The persistent audio widget retains its current compact information: microphone
  state, speaker state, and output volume. Further decisions about its content and
  hierarchy belong to the audio widget redesign rather than the regional
  composition model.

## Composition sketches

These are spatial sketches, not proposed silhouettes or visual styling. Brackets
represent independently positioned widgets, and the centre column remains anchored
to the monitor rather than to the space left over by the side regions.

### Resting state

```text
LEFT                                    CENTRE                                  RIGHT
[Workspaces] [Launcher] [Window] [Visualizer]          ·          [Notifications] [Audio] [System] [Clock]
```

The centre is intentionally empty. Persistent widgets retain their space in quiet
states; the side groups do not expand into the centre.

### Focused application and active media

```text
LEFT                                    CENTRE                                  RIGHT
[Workspaces] [Launcher] [Window] [Visualizer]      [Player]        [Notifications] [Audio] [System] [Clock]
```

The window context stays with navigation. The player appears and disappears around
the physical centre without moving either side group.

### Notification and privacy attention

```text
LEFT                                    CENTRE                                  RIGHT
[Workspaces] [Launcher] [Window] [Visualizer]      [Player]        [Notifications !] [Audio] [System PRIVACY] [Clock]
```

Notification and privacy states remain independently identifiable. Neither is
collapsed into a combined warning, and their emphasis does not reflow the bar.

### Expanded navigation and system surfaces

```text
[Workspaces] [Launcher*] [Window] [Visualizer]      [Player]        [Notifications] [Audio] [System*] [Clock]
                 |                                                       |
        +----------------------+                           +---------------------------+
        | apps / windows /     |                           | connectivity / privacy /  |
        | commands / actions   |                           | tray / session / settings |
        +----------------------+                           +---------------------------+
```

Each expanded surface has an unambiguous origin. The diagram shows both origins for
comparison; normal interaction may permit only one expanded surface at a time.

### Constrained width

```text
Normal   [Workspaces] [Launcher] [Window] [Visualizer]   [Player]   [Notifications] [Audio] [System] [Clock]
Compact  [Workspaces] [Launcher]           [Visualizer]   [Player]   [Notifications] [Audio] [System] [Time]
Narrow   [Workspaces]                                   [Player]                   [Audio]          [Time]
Minimum  [Workspaces]                                                                         [Time]
```

Each row is reached only when the previous row can no longer preserve required
widget space. Exceptional widgets are promoted back into a narrow composition by
displacing its lowest-priority normal-state content.

## Implementation follow-up

The sketches establish information placement and relative priority. A small
implementation prototype should verify true monitor centring and
demonstrate that centre content can appear and disappear without reflowing the side
regions. That prototype belongs to implementation planning rather than changing
the regional contract recorded here.

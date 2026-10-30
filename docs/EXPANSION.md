# Expansion and Disclosure Contract

## Status and purpose

This document defines the shared lifecycle contract for shell controls that reveal
larger surfaces. It turns the observable behavior in `INTERACTION_GRAMMAR.md` into
an architectural state model that can be implemented consistently across
`PopupWindow`, `PanelWindow`, and future presentation types.

This is a contract for ownership, state, dismissal, focus, and window lifetime. It
does not prescribe a single animation or surface shape. Geometry mapping,
presentation adapters, motion tokens, and the final consumer API will be specified
as those parts are implemented and validated.

The terms **must**, **should**, and **may** describe required behavior, preferred
defaults, and supported variation respectively.

## Terms

- **Origin**: the compact control from which a disclosure is opened.
- **Disclosure**: the complete origin-to-surface relationship and its lifecycle.
- **Surface**: the expanded visual and interactive content, including its native
  compositor window.
- **Scope**: the group within which ordinary disclosures are mutually exclusive.
- **Requested state**: the latest intent to have a disclosure open or closed.
- **Lifecycle state**: the effective state of the disclosure while it moves toward
  the requested state.
- **Mapped**: the native window exists as a compositor surface and may be rendered.
- **Interactive**: the surface may accept pointer or keyboard input. A mapped
  surface is not necessarily interactive.

## Ownership

Each disclosure has one lifecycle owner. That owner is the sole authority for its
requested state and lifecycle state. Origins, presentation adapters, focus grabs,
and content may request a transition, but must not independently assign window
visibility or lifecycle state.

The disclosure owner is responsible for:

- accepting open and close requests;
- resolving replacement with another disclosure in the same scope;
- driving the lifecycle toward the latest requested state;
- keeping origin state, surface mapping, input, and focus synchronized;
- reporting why a close was requested; and
- reaching a stable state even when animation is absent or interrupted.

Widget content remains responsible for its feature data and actions. A presentation
adapter remains responsible for the mechanics of its native window type. Neither
may create a second, competing source of open state.

An origin and surface may be recreated during a shell reload, but lifecycle state
is not persisted across generations. A new generation starts closed unless a new
explicit open request is made.

## Scope and exclusivity

An ordinary interactive disclosure belongs to an explicit scope. Initially, the
scope should represent the shell on one output. Opening a disclosure requests that
another ordinary disclosure in the same scope close. Disclosures on different
outputs may coexist when the shell later supports independent per-output origins.

A replacement request does not require the previous disclosure to finish closing
before the new disclosure can begin opening. The coordinator may overlap their
transitions when input ownership and focus remain unambiguous. At most one ordinary
disclosure in a scope may be the active interactive surface.

Transient surfaces such as notification toasts may be declared outside ordinary
exclusivity. They must not take keyboard focus from the active disclosure and must
not silently become part of its lifecycle. Modal confirmation or destructive flows
may use a stricter policy, but must declare that policy rather than weakening the
ordinary non-modal contract.

## Requested state and lifecycle state

The requested state is a boolean intent: open or closed. The lifecycle state is one
of four values:

| State | Meaning | Requested state | Surface mapping |
| --- | --- | --- | --- |
| `closed` | No effective disclosure is present. | Closed | Unmapped |
| `opening` | The disclosure is progressing toward open. | Open | Mapped |
| `open` | The disclosure is fully available. | Open | Mapped |
| `closing` | The disclosure is progressing toward closed. | Closed | Mapped until completion |

Only `closed` and `open` are stable states. `opening` and `closing` are transitional
even when their presentation resolves immediately under reduced motion.

### State transitions

| Current state | Open request | Close request | Transition completion |
| --- | --- | --- | --- |
| `closed` | Map, then enter `opening`. | No change. | Not applicable. |
| `opening` | Continue toward `open`. | Reverse into `closing` from the current progress. | Enter `open` only if open is still requested. |
| `open` | No change. | Enter `closing`. | Not applicable. |
| `closing` | Reverse into `opening` from the current progress. | Continue toward `closed`. | Enter `closed` only if closed is still requested. |

The latest request wins. Transition completion callbacks must re-check the current
request and must never overwrite a newer request with a stale final state.

Reversal starts from the current visual progress. It must not jump to the opposite
endpoint, restart from a hard-coded initial value, briefly unmap, or produce an
intermediate stable state. Transition progress is presentation data; it is not the
source of truth for whether the disclosure has been requested open.

When motion is disabled, the same state transitions occur conceptually and settle
without a perceptible duration. Code that performs mapping, focus, input, or cleanup
must therefore follow lifecycle state rather than depend on an animation signal.

## Effective open state

The origin's semantic `open` state is effective throughout `opening`, `open`, and
`closing`. It becomes false only on entry to `closed`. This keeps the origin and
surface visibly related and prevents the origin from appearing idle while its
surface is still on screen.

The surface must be mapped before entering `opening` and must remain mapped through
`closing`. It may be unmapped only after entering `closed`. Window visibility is
therefore a consequence of lifecycle state, not an alias for requested state.

Input may be enabled after mapping when the adapter can safely receive it. During
closing, the surface should cease accepting new feature actions as soon as doing so
will not break the dismissal interaction. Native input masks must exclude the
surface no later than entry to `closed`, before or at unmapping, so an invisible
window cannot intercept desktop or application input.

## Requests and dismissal reasons

All transitions enter through open or close requests. A close request carries a
reason so focus policy, diagnostics, and consumers do not infer intent from timing
or pointer state.

The shared reasons are:

| Reason | Source | Default focus behavior |
| --- | --- | --- |
| `origin-toggle` | The active origin is activated again. | Preserve the current input path; restore only when keyboard initiated. |
| `escape` | `Escape` is handled by the surface or origin. | Restore focus to the origin. |
| `outside-activation` | Activation occurs outside both origin and surface. | Do not move focus back to the origin. |
| `focus-loss` | A platform focus grab is cleared by an outside interaction. | Do not steal focus back from the new target. |
| `replacement` | Another disclosure opens in the same scope. | Transfer focus according to the replacement's open request. |
| `origin-unavailable` | The origin is destroyed, hidden, disabled, or loses the service required to open. | Do not attempt restoration. |
| `programmatic` | Feature logic, IPC, reload cleanup, or another explicit caller closes it. | Caller states whether restoration is required. |

Presentation-specific events must be translated into these shared reasons before
requesting a close. A focus grab clearing, for example, requests
`focus-loss`; it must not directly hide its window.

An outside activation is outside only when its target belongs to neither the origin
nor the surface. Moving focus between them is internal. The press/release sequence
that opens a disclosure must be treated as one activation and must not also count as
an outside activation. Implementations may use event identity, an activation
generation, or a narrowly scoped guard; an arbitrary delay is not part of the
contract.

## Origin validity

An open request is valid only while its origin exists and can supply usable
geometry. If the origin is destroyed, hidden by responsive composition, moved to a
different scope, or becomes unavailable for its promised feature, the lifecycle
owner requests `origin-unavailable` closure.

Temporary data updates that do not invalidate the feature must not close the
surface. Content should instead represent its loading or unavailable state where
that remains useful. A consumer must explicitly distinguish degraded content from
an origin that can no longer own a disclosure.

Geometry changes while open do not create a new lifecycle. They update the current
origin relationship and presentation placement. If usable geometry cannot be
recovered, the disclosure closes rather than remaining visually detached.

## Focus policy

The open request records its input source and, when applicable, the focus target to
enter. Pointer activation must not manufacture visible keyboard focus. Keyboard,
shortcut, or IPC activation that expects immediate interaction should move focus to
the surface after it is mapped and able to accept focus.

Focus restoration is based on dismissal reason, not on every close:

- `escape` restores focus to the origin when it still exists and is focusable;
- keyboard `origin-toggle` restores focus to the origin;
- `outside-activation` and `focus-loss` preserve the user's new focus destination;
- `replacement` allows the incoming disclosure to claim focus without an
  intermediate focus jump; and
- `origin-unavailable` never attempts to focus the invalid origin.

A programmatic close must state its restoration intent. If restoration is required
but the origin is no longer focusable, focus returns to the containing shell
navigation scope when available; otherwise it is released. Focus must never remain
inside a `closed`, hidden, or unavailable surface.

Focus entry and restoration are lifecycle effects, not animation effects. Reduced
motion and interrupted transitions must produce the same focus destination.

## Native window lifetime

The lifecycle contract distinguishes the native surface lifetime from visible
content progress:

1. Accept a valid open request.
2. Resolve same-scope exclusivity.
3. Map and configure the native window.
4. Enter `opening` and enable input/focus at the adapter's safe point.
5. Enter `open` when the opening transition settles and the request is still open.
6. On a close request, enter `closing` and release exclusive input/focus as required
   by the dismissal reason.
7. Enter `closed`, remove the native input region, then unmap.

Adapters may need a mapped frame before geometry or focus is valid. They may defer
transition progress or focus entry until that frame, but the disclosure remains in
`opening`; consumers must not assign a competing temporary state.

The contract applies equally when a `PopupWindow` can use native popup dismissal
and when a `PanelWindow` requires an explicit layer-shell mask and focus grab.
Those mechanisms are adapter inputs to the lifecycle, not alternative lifecycle
owners.

## Compositor and material constraints

`PopupWindow`, `PanelWindow`, and the fullscreen canopy are distinct compositor
surfaces. Hyprglass and similar compositor effects process those surfaces
independently. The shell cannot assume that adjacent or overlapping windows share
one blur sample, border, alpha composition, shadow, or clipping context.

Consequently, shared expansion promises perceptual continuity, not a literal
cross-window material morph. Presentations should establish continuity through:

- accurate origin geometry and attachment direction;
- coordinated origin and surface state;
- a shared edge or connector owned by one surface where practical;
- synchronized, reversible reveal progress; and
- avoidance of overlapping translucent treatments that create doubled blur,
  borders, or visible seams.

The base lifecycle must remain correct when compositor effects are disabled. Any
presentation that relies on a particular compositor effect requires a legible
fallback and must be validated both with and without that effect.

## Invariants

An implementation of this contract must preserve these invariants:

1. One lifecycle owner is authoritative for each disclosure.
2. The latest request wins, including during transition completion.
3. Effective open state remains true until lifecycle state is `closed`.
4. A closing surface remains mapped until closing completes.
5. At most one ordinary disclosure per scope is interactive.
6. A closed disclosure has no native input region and holds no focus.
7. Dismissal reason, not animation timing, determines focus restoration.
8. Origin loss produces a safe close rather than a detached surface.
9. Reduced motion changes presentation duration, not lifecycle semantics.
10. Compositor-specific visual effects are optional enhancements, not correctness
    dependencies.


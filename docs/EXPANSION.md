# Expansion and Disclosure Contract

## Status and purpose

This document defines the shared lifecycle contract for shell controls that reveal
larger surfaces. It turns the observable behavior in `INTERACTION_GRAMMAR.md` into
an architectural state model that can be implemented consistently across
`PopupWindow`, `PanelWindow`, and future presentation types.

This is both the contract for ownership, state, dismissal, focus, and window
lifetime and the adoption guide for the implemented consumer API. It does not
prescribe a single animation or surface shape. Consumers share lifecycle and
window mechanics while retaining control of their content and presentation.

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

## Implemented architecture

The implementation separates policy from native-window mechanics and widget
content:

| Layer | Component | Responsibility |
| --- | --- | --- |
| Lifecycle | `DisclosureLifecycle` | Requested state, effective state, transition progress, mapping requests, focus policy, dismissal reason, and safe reversal. |
| Coordination | `DisclosureCoordinator` | One active ordinary disclosure per scope and replacement of the previous active disclosure. |
| Geometry | `DisclosureGeometry` | Origin mapping, attachment edge, constrained surface placement, and connector geometry. |
| Popup adapter | `DisclosurePopup` | `PopupWindow` anchoring, focus, mapping, click-away, Escape, and lifecycle integration. |
| Panel adapter | `DisclosurePanel` | Layer-shell anchors, input mask, focus grab, click-through behavior, and lifecycle integration. |
| Base presentation | `DisclosureSurface` | Directional reveal, surface treatment, connector, padding, and content host. |
| Origin presentation | `InteractiveIsland` or equivalent | Activation, visible open state, keyboard semantics, and accessible origin identity. |
| Consumer | Feature widget and content | Feature data, actions, content layout, availability, and the choice of adapter/presentation. |

Consumers normally use an adapter and `DisclosureSurface`; they do not construct
`DisclosureLifecycle`, `DisclosureGeometry`, or coordinator registration
directly. The adapters own those objects and expose the parts consumers need.

## Choosing an adapter

Use `DisclosurePopup` for a compact surface anchored to an item, such as media,
audio, a calendar, or a small system menu. It sizes to `implicitWidth` and
`implicitHeight` and follows popup anchoring rules.

Use `DisclosurePanel` when the expanded content must be a layer-shell surface,
occupy a monitor edge, or use a custom input region. Notifications use this path.
The consumer supplies layer anchors and an `inputTarget` that exactly describes
the interactive disclosure; the rest of a transparent panel remains
click-through.

Do not choose `PanelWindow` merely to gain more drawing space. It has stronger
compositor, focus-grab, and input-mask consequences than an anchored popup. A
transient toast or tooltip is not an ordinary disclosure and should not join the
exclusive coordinator unless it intentionally behaves like one.

## Adapter API

`DisclosurePopup` and `DisclosurePanel` expose the same lifecycle-facing API:

| Member | Meaning |
| --- | --- |
| `origin` | Required item that owns and geometrically anchors the disclosure. |
| `scopeId` | Exclusivity scope; defaults to `DisclosureCoordinator.defaultScope`. |
| `exclusiveInScope` | Whether opening replaces the active ordinary disclosure in the scope. Defaults to `true`. |
| `originAvailable` | Set false when the feature can no longer support the disclosure. |
| `focusOnOpen` | Whether the adapter should focus its initial target once mapped. |
| `clickAwayEnabled` | Whether loss of the adapter's focus grab requests a normal close. |
| `reducedMotion` | Presentation preference; defaults to `MotionPreferences.reducedMotion`. |
| `originEdge` | Edge from which placement and reveal direction are derived. |
| `surfaceGap` | Distance between the origin anchor and expanded surface. |
| `screenMargin` | Minimum fitting margin inside available output geometry. |
| `initialFocusTarget` | Item focused after a keyboard, shortcut, or IPC open. |
| `lifecycle` | Read-only `DisclosureLifecycle` used by origins and diagnostics. |
| `geometry` | Read-only `DisclosureGeometry` supplied to the presentation. |
| `revealProgress` | Read-only normalized transition progress for presentations. |
| `effectiveOpen` | True during opening, open, and closing. |
| `interactionEnabled` | True only while mapped and safe to interact with. |
| `requestOpen(inputSource)` | Requests open and returns whether state changed. |
| `requestClose(reason, inputSource, restoreFocus)` | Requests a reasoned close. |
| `toggle(inputSource)` | Requests the opposite of the latest open intent. |

`DisclosurePanel` additionally exposes `inputTarget` and `layerNamespace`.
`inputTarget` must cover every interactive part of the panel and nothing else.
The adapter uses it for both geometry and its native input mask.

The lifecycle's `requestedOpen` answers what the latest request wants;
`effectiveOpen` answers whether the disclosure still exists visibly. Origins
must use `effectiveOpen`, usually by passing `lifecycle` to
`InteractiveIsland.disclosure`. Consumers must not bind origin open treatment or
native window visibility directly to `requestedOpen`.

## Minimal popup consumer

The feature widget receives the actual origin item, exposes its lifecycle to that
origin, and delegates open/close requests to the adapter:

```qml
// ExampleDetailsWidget.qml
import qs.components
import qs.config
import QtQuick

Item {
    id: root

    required property Item popupOrigin

    implicitWidth: compactLabel.implicitWidth
    implicitHeight: compactLabel.implicitHeight

    readonly property alias disclosure: details.lifecycle

    function toggleDetails(inputSource): bool {
        return details.toggle(inputSource);
    }

    Text {
        id: compactLabel
        text: "Details"
    }

    DisclosurePopup {
        id: details

        origin: root.popupOrigin
        originAvailable: root.visible && root.enabled
        originEdge: DisclosureGeometry.Bottom
        implicitWidth: 320
        implicitHeight: 180
        initialFocusTarget: firstAction

        DisclosureSurface {
            anchors.fill: parent
            geometry: details.geometry
            revealProgress: details.revealProgress
            originEdge: details.originEdge
            connected: true
            accentColor: Theme.accentCyan

            Column {
                anchors.fill: parent
                spacing: 8

                Text { text: "Details" }

                FocusScope {
                    id: firstAction
                    activeFocusOnTab: true
                    width: parent.width
                    height: 32
                    // Feature-specific action and visuals belong here.
                }
            }
        }
    }
}
```

The bar or containing composition wires that widget to an interactive origin:

```qml
InteractiveIsland {
    id: detailsOrigin

    disclosure: detailsWidget.disclosure
    accessibleName: "Details"
    onPrimaryTriggered: inputSource => detailsWidget.toggleDetails(inputSource)
    onEscapeRequested: detailsWidget.disclosure.requestClose(
        DisclosureLifecycle.Escape,
        DisclosureLifecycle.Keyboard
    )

    ExampleDetailsWidget {
        id: detailsWidget
        popupOrigin: detailsOrigin
    }
}
```

The same consumer can use `DisclosurePanel` instead when its native-window needs
require it. Its content still receives `geometry`, `revealProgress`, and
`originEdge` through `DisclosureSurface`; only the adapter-specific anchors,
size, and input target change.

## Consumer responsibilities

The origin is responsible for:

- passing the real activation input source to `toggle` or `requestOpen`;
- deriving its visible open treatment from the adapter lifecycle;
- providing keyboard activation, Escape routing, accessibility name, and a
  stable practical hit target; and
- remaining a valid geometry source while the disclosure is effective.

The feature widget is responsible for:

- selecting the adapter and attachment edge;
- declaring when its origin or backing service is truly unavailable;
- supplying feature data, actions, and content states;
- choosing an initial focus target and a useful internal focus order; and
- exposing a small feature-facing API instead of leaking native window details
  throughout the bar.

The adapter is responsible for mapping, unmapping, focus entry and release,
Escape, click-away/focus-loss translation, native input regions, geometry
refresh, and forwarding lifecycle state. A consumer must not duplicate those
mechanisms or directly assign adapter `visible`, focus-grab state, or masks.

The presentation is responsible for drawing the relationship: it consumes
geometry and reveal progress, keeps content legible, and may choose another
visual treatment. It must not decide whether the disclosure is open. When using
`DisclosureSurface`, the connector is deliberately drawn inside the disclosure
surface so independently composited glass windows do not overlap at the shared
edge.

## Focus, dismissal, and availability

Always pass the actual input source. Treating a keyboard open as programmatic or
pointer input prevents the lifecycle from applying the correct focus behavior.
Set `initialFocusTarget` to the content scope or first useful control; every
interactive child remains responsible for normal `Tab`, arrow-key, and semantic
control behavior.

Use the shared `DisclosureLifecycle` reason and input enums when closing. Feature
logic may request `Programmatic`, but origin toggle, Escape, replacement, focus
loss, and unavailable-origin paths must retain their distinct reasons so focus
restoration remains predictable.

Set `originAvailable` false only when the origin can no longer own a meaningful
surface. A temporary loading state or missing field belongs in feature content
and normally does not invalidate the origin. If responsive composition hides or
replaces the origin, the lifecycle safely closes rather than retaining detached
geometry.

## Scope and transient surfaces

The current default scope is `"shell"`. Consumers on the same shell therefore
replace one another without widget-specific knowledge. A future per-output
composition should pass a stable output-specific `scopeId` to every ordinary
disclosure on that output.

Set `exclusiveInScope: false` only for a surface that is intentionally allowed to
coexist and whose focus behavior supports that choice. Notification toasts are
separate transient windows rather than non-exclusive notification-centre
disclosures; they do not register with the coordinator or steal disclosure
focus.

## Reduced motion and custom presentations

Adapters default to the shared reduced-motion preference. The lifecycle settles
to the same requested state, mapping, focus, and geometry whether motion runs or
not. A custom presentation may replace travel with an immediate state change or
brief fade, but must consume lifecycle progress rather than create a second open
state or wait for its own animation to authorize cleanup.

`DisclosureSurface` is the baseline, not a mandatory visual identity. A consumer
may implement another reveal, shared-edge, or connector treatment using
`geometry`, `revealProgress`, and `originEdge`. It must preserve the invariants
below and remain usable with compositor effects disabled.

## Compositor-specific behavior

Quickshell popup and panel adapters are separate Wayland surfaces from the frame
and from each other. No API can make Hyprglass sample them as one physical piece
of glass. The connector and coordinated state create perceptual continuity while
avoiding the doubled blur and border produced by overlapping translucent
surfaces.

`HyprlandFocusGrab` also means an outside pointer activation may be consumed while
it dismisses a panel. In the validated notification-to-media path, the first
click closes notifications and the following click opens media. This is a native
focus-grab handoff, not a second lifecycle. Code must not simulate click replay or
delay closure to disguise it without a compositor-safe input design.

The implementation and visual treatment have been exercised with Hyprglass both
enabled and disabled. See `EXPANSION_VALIDATION.md` for the session matrix,
qualified pointer handoff, and revalidation guidance.

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

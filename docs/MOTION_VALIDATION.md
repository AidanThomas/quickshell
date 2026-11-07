# Motion System Validation

## Session

Validated on 2026-11-07 against the running repository configuration and the
existing disclosure resilience harness.

- Hyprland 0.56.2
- Hyprglass 1.0.0 loaded
- Quickshell running from this checkout
- Active MPRIS media, Cava, notifications, and application content
- Normal-motion and `QUICKSHELL_REDUCED_MOTION=1` startup configurations

The compositor-disabled disclosure/material baseline remains recorded in
`EXPANSION_VALIDATION.md`. The motion work does not change native-window geometry,
blur ownership, connectors, or material composition; it changes shared timing,
easing, and reduced-motion resolution.

## Results

| Area | Result | Notes |
| --- | --- | --- |
| Motion audit | Pass | Every live QML animation maps to feedback, state, spatial, disclosure, transient, or ambient motion in `MOTION.md`. |
| Startup flourish | Pass | No per-widget startup scale, opacity, spring, or overshoot remains. The bar loads directly into its current composition. |
| Semantic tokens | Pass | All animation consumers use the role-specific duration and easing tokens in `Theme.qml`; obsolete generic and entrance tokens have no consumers. |
| Persistent interaction | Pass | Hover, focus, press, and semantic state behaviors remain non-spatial and resolve through the shared reduced-motion preference. |
| Workspace movement | Pass | Directional positional motion retains its destination cue; enabling reduced motion stops travel and settles at the current workspace. |
| Centre occupancy | Pass | Media occupancy animates only the independently centred region; left and right anchors do not depend on its width. Reduced motion uses immediate geometry. |
| Disclosure interruption | Pass | The automated harness passed twice after repeated reversal, replacement, geometry changes, origin loss, and enabling reduced motion during an active close. |
| Notification transient | Pass | Toast arrival and stack motion use bounded non-overshooting transient motion. Removal delay derives from the same role and becomes immediate under reduced motion. |
| Ambient motion | Pass | Cava is the only continuous ambient animation. Its process and interpolation stop under reduced motion and resume only for later live data. |
| Normal startup | Pass | A fresh short-lived instance reached `Configuration Loaded` without QML, binding-loop, animation, or geometry errors. The expected notification-server ownership warning occurred because the primary shell remained active. |
| Reduced-motion startup | Pass | A fresh instance with `QUICKSHELL_REDUCED_MOTION=1` reached `Configuration Loaded` with the same expected second-instance notification warning and no motion-specific errors. |
| Hyprglass enabled | Pass | The active plugin remained loaded while Cava, media, application content, and a test notification exercised the current shell. No runtime error followed. |
| Hyprglass disabled | Pass (inherited baseline) | `EXPANSION_VALIDATION.md` records the same disclosure geometry and material presentation with the plugin disabled. This change introduces no compositor-dependent presentation path. |
| Static checks | Pass | `qmllint` completed without a fatal diagnostic; unresolved import warnings are caused by running it outside Quickshell's generated import environment. `git diff --check` passed. |

## Automated coverage

`tests/run-disclosure-resilience.sh` runs the lifecycle scenario twice. Its final
stage now begins an animated close, verifies that progress is genuinely between
the endpoints, enables reduced motion, and asserts a fully closed, unmapped,
non-intercepting endpoint. Earlier stages cover rapid reversal, same-scope
replacement, origin loss, service loss, and live geometry changes.

## Revalidation

Re-run the disclosure harness after changing lifecycle progress or reduced-motion
handling. For live changes, use a fresh startup or no-content reload log window;
development hot reload history may contain warnings from intermediate generations
whose token definitions and consumers were edited separately.

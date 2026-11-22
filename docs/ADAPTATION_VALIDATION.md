# Adaptation Validation

## Environment

Validated on 2026-11-22 with Quickshell 0.3.2 and Hyprland's Lua runtime
configuration API. The physical layout contained a 2560×1440 primary landscape
output and a rotated 2560×1440 secondary output. Temporary headless outputs were
created and removed for hotplug coverage.

## Results

| Area | Result | Evidence |
| --- | --- | --- |
| Minimum width | Pass | DP-1 ran at 1600×900 and scale 2, producing 800×450 logical geometry. Workspaces, meaningful unread notification state, audio, and time fit without overlap; media and ambient visualization yielded. |
| Compact breakpoint | Pass | DP-1 ran at 1920×1080 and scale 2, producing 960×540 logical geometry. The compact composition fit without overlap and retained the 52px reservation. |
| Full breakpoint | Pass | DP-1 ran at 2560×1440 and scale 2, producing 1280×720 logical geometry. Full composition and ambient visualization returned at the inclusive breakpoint. |
| Normal full width | Pass | The restored 2560×1440 logical layout retained independently anchored left, centre, and right regions. |
| Maximum declared width | Pass by policy test | `LayoutPolicy.modeForWidth(3840)` resolves to `Full`. The physical outputs do not expose a native 3840-logical-pixel mode; full-profile geometry is width-independent above 1280. |
| Scale range | Pass | Live compositor checks covered scale 1, 2, and 2.5. Automated breakpoint checks are scale-independent because the policy consumes logical geometry. |
| Portrait secondary | Pass | Rotated DP-3 retained one 146×52 top-right glance surface, no exclusive reservation, and no full frame. |
| Secondary hotplug | Pass | Creating `HEADLESS-1` immediately created one glance surface. Removing it immediately removed the surface with no stale layer or reservation. |
| Primary stability during rearrangement | Pass | Moving the selected primary away from compositor origin did not unexpectedly transfer controls while it remained available. Origin selection is a fallback, not a dynamic focus policy. |
| Keyboard entry | Pass | `bar.focus()` focused the first primary-bar control and produced a visible focus treatment. `bar.unfocus()` released it. Existing expansion validation covers Tab order, activation, Escape, and restoration. |
| Reduced motion | Pass | The disclosure resilience suite changes reduced motion during a transition and reaches the same final geometry, input, and focus state. Ambient consumers already stop through `MotionPreferences`. |
| Hot reload and logs | Pass | Repeated reloads completed without new QML errors, binding loops, stale focus, or layer-shell warnings. |

## Automated checks

`tests/run-layout-policy.sh` covers the 800, 960, 1280, and 3840 width decisions,
origin-based primary selection, portrait/secondary retention, and an empty screen
model. `tests/run-disclosure-resilience.sh` covers rapid lifecycle reversal,
replacement, service loss, live geometry changes, reduced motion, input masks, and
cleanup. Both pass from a clean invocation.

## Restored state

DP-1 was restored to 2560×1440 at 165Hz, scale 1, and position `(0,0)` after the
tests. All temporary headless outputs were removed. DP-3 retained its original
rotation and position.

# Shell icons

The shell-authored interface uses a small vendored subset of
[Phosphor Icons](https://phosphoricons.com/) in its **Fill** weight.
Application icons, notification artwork, weather artwork, and
StatusNotifier-provided assets do not use this system.

- Source revision: `2b75f3ad12b420c9504ef05df8d2564a28f8500e`
- Retrieved: 2026-11-22
- Upstream paths: `assets/fill/*-fill.svg` (vendored as `*-fill-mask.svg`)
- Licence: MIT; see `LICENSE`

The files retain Phosphor's 256 by 256 filled geometry. Their fill is
normalized to white so `ShellIcon.qml` can apply the shell's semantic colour
in a single colorization pass at render time.

Only add an asset when shell UI uses it. Call sites should refer to semantic
names exposed by `ShellIcon`, never directly to these paths.

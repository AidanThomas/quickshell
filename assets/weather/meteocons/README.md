# Meteocons weather assets

Selected flat SVGs from `@meteocons/svg-static` version 0.1.0 and matching
Lottie JSON from `@meteocons/lottie` version 0.1.0.

The live forecast uses Lottie when motion is enabled. The official static SVGs
are shown when reduced motion is enabled, while Lottie is loading, or if an
animation cannot be decoded. No upstream artwork is modified.

Runtime Lottie support comes from Qt's `Qt.labs.lottieqt` module. The desktop
home configuration wraps Quickshell with `qtlottie` on its QML import and plugin
paths so the dependency is explicit and reproducible rather than supplied by an
ambient development environment.

Copyright (c) Bas Milius. Distributed under the MIT licence in `LICENSE`.

Source: https://github.com/basmilius/meteocons

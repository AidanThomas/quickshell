#!/usr/bin/env bash
set -euo pipefail

repository_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
runtime_root=$(mktemp -d --tmpdir quickshell-disclosure-test.XXXXXXXX)

cleanup() {
    rm -r -- "$runtime_root"
}
trap cleanup EXIT

ln -s "$repository_root/components" "$runtime_root/components"
ln -s "$repository_root/config" "$runtime_root/config"
ln -s "$repository_root/widgets" "$runtime_root/widgets"
cp "$repository_root/tests/disclosure/Resilience.qml" "$runtime_root/shell.qml"

for run in 1 2; do
    output=$(timeout --signal=KILL 7s quickshell -p "$runtime_root" 2>&1)
    printf '%s\n' "$output"
    grep -q "DISCLOSURE_RESILIENCE_PASS" <<<"$output"
done

#!/usr/bin/env bash
set -euo pipefail

repository_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
runtime_root=$(mktemp -d --tmpdir quickshell-layout-test.XXXXXXXX)

cleanup() {
    rm -r -- "$runtime_root"
}
trap cleanup EXIT

ln -s "$repository_root/config" "$runtime_root/config"
cp "$repository_root/tests/layout/Policy.qml" "$runtime_root/shell.qml"

output=$(timeout --signal=KILL 5s quickshell -p "$runtime_root" 2>&1)
printf '%s\n' "$output"
grep -q "LAYOUT_POLICY_PASS" <<<"$output"

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

LIVE_HTML="$(mktemp)"
trap 'rm -f "$LIVE_HTML"' EXIT

curl -fsS http://127.0.0.1:8080/dashboard -o "$LIVE_HTML"

echo "=== LOCAL FILE: malformed attribute-only lines ==="
rg -n '^[[:space:]]+id="[^"]+"' public/dashboard.html || true

echo
echo "=== LIVE HTML: malformed attribute-only lines ==="
rg -n '^[[:space:]]+id="[^"]+"' "$LIVE_HTML" || true

echo
echo "=== LOCAL FILE: telemetry section hits ==="
rg -n 'phase61-telemetry-column|activity-panels-heading|observational-workspace-card|observational-tabs|observational-panels' public/dashboard.html || true

echo
echo "=== LIVE HTML: telemetry section hits ==="
rg -n 'phase61-telemetry-column|activity-panels-heading|observational-workspace-card|observational-tabs|observational-panels' "$LIVE_HTML" || true

echo
echo "=== LOCAL FILE: surrounding slice ==="
nl -ba public/dashboard.html | sed -n '145,220p'

echo
echo "=== LIVE HTML: surrounding slice ==="
nl -ba "$LIVE_HTML" | sed -n '145,220p'

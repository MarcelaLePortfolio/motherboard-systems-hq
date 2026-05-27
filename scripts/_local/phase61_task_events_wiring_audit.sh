#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

echo "==> Phase 61 Task Events wiring audit"
echo

echo "-- dashboard references --"
grep -RniE 'task events|task-events|Task Events|EventSource|SSE|telemetry|recent tasks|task history' public src scripts server . 2>/dev/null || true

echo
echo "-- dashboard html hooks --"
grep -nE 'task-events|Task Events|telemetry|observational-workspace|workspace-card' public/dashboard.html 2>/dev/null || true

echo
echo "-- probable JS render/update paths --"
grep -RniE 'appendChild|innerHTML|textContent|createElement|render.*task|update.*task|event.*row|event.*list' public src server . 2>/dev/null || true

echo
echo "==> audit complete"

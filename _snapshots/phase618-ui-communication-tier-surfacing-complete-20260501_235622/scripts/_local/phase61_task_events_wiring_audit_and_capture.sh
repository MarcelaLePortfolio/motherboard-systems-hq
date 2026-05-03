#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

OUT_DIR="docs/checkpoints"
OUT_FILE="$OUT_DIR/PHASE61_4_TASK_EVENTS_WIRING_AUDIT_20260310.txt"

mkdir -p "$OUT_DIR"

{
  echo "Phase 61.4 — Task Events Wiring Audit"
  echo "Date: 2026-03-10"
  echo "Branch: $(git branch --show-current)"
  echo "HEAD: $(git rev-parse --short HEAD)"
  echo

  echo "==> dashboard references"
  grep -RniE 'task events|task-events|Task Events|EventSource|SSE|telemetry|recent tasks|task history' public src scripts server . 2>/dev/null || true
  echo

  echo "==> dashboard html hooks"
  grep -nE 'task-events|Task Events|telemetry|observational-workspace|workspace-card' public/dashboard.html 2>/dev/null || true
  echo

  echo "==> probable JS render/update paths"
  grep -RniE 'appendChild|innerHTML|textContent|createElement|render.*task|update.*task|event.*row|event.*list' public src server . 2>/dev/null || true
  echo

  echo "==> likely event-related functions"
  grep -RniE 'function .*event|const .*event|render.*event|update.*event|append.*event|hydrate.*event|telemetry.*event|taskEvents|task_events' public src server . 2>/dev/null || true
  echo

  echo "==> likely event stream endpoints"
  grep -RniE '/api/.*event|/events|EventSource\\(|text/event-stream|task-events|telemetry' public src server . 2>/dev/null || true
  echo
} | tee "$OUT_FILE"

echo
echo "Saved audit output to $OUT_FILE"

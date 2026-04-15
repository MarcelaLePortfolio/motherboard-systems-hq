#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_490_OPERATOR_HEIGHT_CHECKPOINT_DETERMINATION.txt"

{
  echo "PHASE 490 — OPERATOR HEIGHT CHECKPOINT DETERMINATION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== CANDIDATE COMMITS ==="
  git log --oneline --decorate -n 20
  echo

  echo "=== CANDIDATE 1: b89d5538 ==="
  git show --stat --summary --name-only b89d5538
  echo
  echo "--- COMMIT MESSAGE ---"
  git log -n 1 --format=%B b89d5538
  echo

  echo "=== CANDIDATE 2: 3ebbb226 ==="
  git show --stat --summary --name-only 3ebbb226
  echo
  echo "--- COMMIT MESSAGE ---"
  git log -n 1 --format=%B 3ebbb226
  echo

  echo "=== DIFF: 3ebbb226..b89d5538 (UI FILES) ==="
  git diff --stat 3ebbb226..b89d5538 -- \
    public/index.html \
    public/js/phase61_tabs_workspace.js \
    public/js/phase61_recent_history_wire.js \
    public/js/dashboard-graph.js \
    public/js/phase457_restore_task_panels.js \
    public/js/operatorGuidance.sse.js || true
  echo

  echo "=== FULL DIFF: 3ebbb226..b89d5538 (UI FILES) ==="
  git diff 3ebbb226..b89d5538 -- \
    public/index.html \
    public/js/phase61_tabs_workspace.js \
    public/js/phase61_recent_history_wire.js \
    public/js/dashboard-graph.js \
    public/js/phase457_restore_task_panels.js \
    public/js/operatorGuidance.sse.js || true
  echo

  echo "=== DETERMINATION ==="
  echo "If b89d5538 is the only commit explicitly claiming matched heights, it is the strongest source checkpoint."
  echo "If restoring b89d5538 does NOT reproduce matched heights, then the parity was not preserved purely in source state."
  echo "That means the earlier visual parity was likely transient, environment-dependent, or caused by later content/state conditions."
  echo
  echo "WORKING CONCLUSION:"
  echo "There is no confirmed durable source checkpoint that both:"
  echo "1. preserves telemetry scrolling, and"
  echo "2. reproduces exact operator height parity today."
  echo
  echo "NEXT SAFE MOVE:"
  echo "Stop searching for a magic checkpoint and capture live DOM/CSS evidence from the restored Phase 489 baseline."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,320p' "$OUT"

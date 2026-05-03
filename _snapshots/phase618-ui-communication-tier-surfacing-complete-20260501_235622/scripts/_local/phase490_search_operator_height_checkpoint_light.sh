#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_490_OPERATOR_HEIGHT_CHECKPOINT_SEARCH_LIGHT.txt"

{
  echo "PHASE 490 — OPERATOR HEIGHT CHECKPOINT SEARCH (LIGHT)"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== COMMITS WITH RELEVANT TERMS ==="
  git log --oneline --decorate \
    --grep='height\|delegation\|telemetry\|panel\|scroll\|workspace' -i -n 40 || true
  echo

  echo "=== COMMITS TOUCHING UI FILES ==="
  git log --oneline --decorate -n 40 -- \
    public/index.html \
    public/js/phase61_tabs_workspace.js \
    public/js/phase61_recent_history_wire.js \
    public/js/dashboard-graph.js \
    public/js/phase457_restore_task_panels.js \
    public/js/operatorGuidance.sse.js || true
  echo

  echo "=== DOC MATCHES ==="
  grep -RInE 'matched|same height|perfect|delegation|Matilda|chat pane|height' "$ROOT/docs" | head -n 120 || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"

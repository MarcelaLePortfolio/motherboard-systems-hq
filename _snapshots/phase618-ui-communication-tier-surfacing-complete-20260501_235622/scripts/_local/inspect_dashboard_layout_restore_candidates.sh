#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/DASHBOARD_LAYOUT_RESTORE_CANDIDATES.txt"

CANDIDATES=(
  "$ROOT/public/dashboard.html"
  "$ROOT/public/dashboard.pre-bundle-tag.html"
  "$ROOT/snapshots/20251114-114821/public/dashboard.html"
  "$ROOT/snapshots/20251114-114707/public/dashboard.html"
  "$ROOT/exports/dashboard_phase6.8/dashboard.html"
  "$ROOT/public/index.html"
)

{
  echo "DASHBOARD LAYOUT RESTORE CANDIDATES"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  for file in "${CANDIDATES[@]}"; do
    [[ -f "$file" ]] || continue
    echo "================================================================"
    echo "FILE: $file"
    echo "================================================================"
    echo
    echo "--- LABEL / ID HITS ---"
    grep -nE 'Agent Pool|Active Agents|Tasks Running|Success Rate|Latency|Recent Tasks|Task Activity|Operator|Telemetry|Subsystem|Matilda|Delegation|agent-status-container|recentTasks|metric-latency|metric-success-rate|metric-agents|task-history|task-activity' "$file" || true
    echo
    echo "--- FIRST 260 LINES ---"
    sed -n '1,260p' "$file"
    echo
  done

  echo "================================================================"
  echo "GIT HISTORY: public/dashboard.html"
  echo "================================================================"
  git log --oneline -- public/dashboard.html | head -n 40 || true
  echo
  echo "================================================================"
  echo "NEXT ACTION"
  echo "================================================================"
  echo "Pick the candidate whose structure shows:"
  echo "1. Agent Pool sharing a row with metrics"
  echo "2. Operator Workspace tab container"
  echo "3. Telemetry Console tab container"
  echo "4. Subsystem Status full-width below"
} > "$OUT"

echo "Wrote $OUT"

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H5_TASK_ACTIVITY_WIRING_TRACE.txt"

{
  echo "PHASE 489 — H5 TASK ACTIVITY WIRING TRACE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== TASK ACTIVITY DOM ANCHORS ==="
  grep -nA20 -B10 'task-activity-graph\|task-activity-card\|obs-panel-activity' "$ROOT/public/index.html" || true
  echo

  echo "=== SERVED SCRIPT TAGS RELEVANT TO TASK ACTIVITY ==="
  curl -s http://localhost:8080 | grep -nE 'dashboard-graph|task-activity|Chart\.js|phase61_tabs_workspace' || true
  echo

  echo "=== TASK ACTIVITY CLIENT FILES ==="
  for f in \
    "$ROOT/public/js/dashboard-graph.js" \
    "$ROOT/public/js/task-activity.js" \
    "$ROOT/public/js/task-activity-graph.js"
  do
    if [[ -f "$f" ]]; then
      echo "--- FILE: $f ---"
      sed -n '1,260p' "$f"
      echo
    fi
  done

  echo "=== CHART / TASK ACTIVITY CODE REFERENCES ==="
  grep -RInE 'task-activity-graph|Chart\\(|new Chart|/api/runs|/api/tasks|events/task-events|task activity' "$ROOT" \
    --include="*.js" --include="*.mjs" --include="*.ts" --include="*.tsx" --include="*.html" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo

  echo "=== LIVE ENDPOINT CHECKS ==="
  for url in \
    "http://localhost:8080/api/runs?limit=20" \
    "http://localhost:8080/api/tasks" \
    "http://localhost:8080/events/task-events?cursor=0"
  do
    echo "--- $url ---"
    curl -i -s --max-time 3 "$url" | sed -n '1,120p' || true
    echo
  done

  echo "=== CURRENT TASKS SNAPSHOT ==="
  curl -s http://localhost:8080/api/tasks | sed -n '1,200p' || true
  echo

  echo "=== NEXT ACTION ==="
  echo "Use this trace to identify the first missing binding for Task Activity and patch only that."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"

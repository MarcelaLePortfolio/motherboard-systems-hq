#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_489_H2_TELEMETRY_WIRING_TRACE.txt"

{
  echo "PHASE 489 — H2 TELEMETRY WIRING TRACE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo

  echo "=== SERVED TELEMETRY SCRIPT TAGS ==="
  curl -s http://localhost:8080 | grep -nE 'phase61_recent_history_wire|dashboard-graph|task-activity|task-events|metric-|QueueLatency|telemetry' || true
  echo

  echo "=== TELEMETRY DOM ANCHORS IN SERVED INDEX ==="
  grep -nA20 -B8 'tasks-widget|task-activity-graph|mb-task-events-panel-anchor|metrics-row|recentTasks|recentLogs|task-activity-card|recent-tasks-card|task-events-card' "$ROOT/public/index.html" || true
  echo

  echo "=== CURRENT TELEMETRY CLIENT FILES ==="
  for f in \
    "$ROOT/public/js/phase61_recent_history_wire.js" \
    "$ROOT/public/js/dashboard-graph.js" \
    "$ROOT/public/js/task-activity.js" \
    "$ROOT/public/js/task-activity-graph.js" \
    "$ROOT/public/js/telemetry/latency_metric.js" \
    "$ROOT/public/js/telemetry/success_rate_metric.js" \
    "$ROOT/public/js/telemetry/queue_latency_metric.js"
  do
    if [[ -f "$f" ]]; then
      echo "--- FILE: $f ---"
      sed -n '1,260p' "$f"
      echo
    fi
  done

  echo "=== LIVE ENDPOINT CHECKS ==="
  for url in \
    "http://localhost:8080/events/task-events" \
    "http://localhost:8080/api/runs?limit=10" \
    "http://localhost:8080/api/tasks" \
    "http://localhost:8080/api/heartbeat"
  do
    echo "--- $url ---"
    curl -i -s "$url" | sed -n '1,80p' || true
    echo
  done

  echo "=== SERVER ROUTES / REFERENCES ==="
  grep -RInE 'task-events|/api/runs|/api/tasks|tasks-widget|task-activity-graph|mb-task-events-panel-anchor|metric-success|metric-latency|metric-tasks|metric-agents' "$ROOT" \
    --include="*.js" --include="*.mjs" --include="*.ts" --include="*.tsx" --include="*.html" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build || true
  echo

  echo "=== NEXT ACTION ==="
  echo "Use this trace to identify the first missing telemetry binding and restore it without backend mutation."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"

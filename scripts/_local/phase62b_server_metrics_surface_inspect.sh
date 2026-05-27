#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_SERVER_METRICS_SURFACE_INSPECTION.txt"
: > "$OUT"

{
  echo "PHASE 62B — SERVER METRICS SURFACE INSPECTION"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== server.mjs: lines 320-470 =="
  if [ -f server.mjs ]; then
    nl -ba server.mjs | sed -n '320,470p'
  else
    echo "server.mjs not found"
  fi
  echo

  echo "== server.mjs: metric-related grep =="
  if [ -f server.mjs ]; then
    grep -nE "runningTasks|completedTasks|failedTasks|queuedTasks|Tasks Running|Tasks Completed|Tasks Failed|metric-running|metric-completed|metric-failed|select count|from tasks|where status" server.mjs || true
  else
    echo "server.mjs not found"
  fi
  echo

  echo "== public/js: metric-related grep =="
  grep -RInE "metric-running|metric-completed|metric-failed|Tasks Running|Tasks Completed|Tasks Failed|runningTasks|completedTasks|failedTasks|queuedTasks" public/js public 2>/dev/null || true
  echo

  echo "== docs/checkpoints: prior running metric references =="
  grep -RInE "runningTasks|Tasks Running|metric-running" docs/checkpoints 2>/dev/null || true
  echo

  echo "== decision =="
  echo "Use this file to identify the exact shared telemetry response shape and exact dashboard binding point before applying the queued metric."
} | tee "$OUT"

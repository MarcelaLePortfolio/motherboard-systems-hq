#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

OUT_DIR="docs/checkpoints"
OUT_FILE="$OUT_DIR/PHASE61_5_RECENT_TASKS_AND_HISTORY_WIRING_AUDIT_20260310.txt"

mkdir -p "$OUT_DIR"

SEARCH_PATHS=(
  public
  server
  src
)

{
  echo "Phase 61.5 — Recent Tasks / Task History Wiring Audit"
  echo "Date: 2026-03-10"
  echo "Branch: $(git branch --show-current)"
  echo "HEAD: $(git rev-parse --short HEAD)"
  echo

  echo "==> recent tasks / task history labels"
  grep -RniE \
    'Recent Tasks|Task History|recent tasks|task history|tasks widget|history widget|recent-tasks|task-history' \
    "${SEARCH_PATHS[@]}" \
    --exclude='*.map' \
    --exclude='*.bak*' \
    --exclude='*.log' \
    2>/dev/null || true
  echo

  echo "==> dashboard html hooks"
  grep -nE \
    'Recent Tasks|Task History|recent-tasks|task-history|obs-panel|workspace-card|phase61' \
    public/dashboard.html \
    2>/dev/null || true
  echo

  echo "==> probable render/update paths"
  grep -RniE \
    'fetch\(|innerHTML|textContent|appendChild|createElement|render.*task|update.*task|history.*render|recent.*render|tasks.*render' \
    "${SEARCH_PATHS[@]}" \
    --exclude='*.map' \
    --exclude='*.bak*' \
    --exclude='*.log' \
    2>/dev/null || true
  echo

  echo "==> probable API endpoints"
  grep -RniE \
    '/api/tasks|/api/runs|/api/history|recent tasks|task history|fetchTasks|loadTasks|loadHistory|fetchHistory' \
    "${SEARCH_PATHS[@]}" \
    --exclude='*.map' \
    --exclude='*.bak*' \
    --exclude='*.log' \
    2>/dev/null || true
  echo

  echo "==> bundle entry references"
  grep -RniE \
    'dashboard-tasks-widget|task-events-sse-client|history|recent tasks|task history' \
    public/js \
    --exclude='*.map' \
    --exclude='*.bak*' \
    --exclude='*.log' \
    2>/dev/null || true
  echo
} | tee "$OUT_FILE"

echo
echo "Saved audit output to $OUT_FILE"

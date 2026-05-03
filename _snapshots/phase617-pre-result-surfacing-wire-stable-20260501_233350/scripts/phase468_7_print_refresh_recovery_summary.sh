#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SRC="docs/phase468_6_tasks_route_minimum_schema_and_verify.txt"
OUT="docs/phase468_7_refresh_recovery_summary.txt"

mkdir -p docs

{
  echo "PHASE 468.7 — REFRESH RECOVERY SUMMARY"
  echo "======================================"
  echo
  echo "SOURCE: $SRC"
  echo

  echo "STEP 1 — /api/tasks response lines"
  rg -n "GET /api/tasks|HTTP/|column|does not exist|CLASSIFICATION" "$SRC" || true
  echo

  echo "STEP 2 — Dashboard entrypoint lines"
  rg -n "GET /dashboard.html|GET /bundle.js|HTTP/" "$SRC" || true
  echo

  echo "STEP 3 — Recent dashboard error lines"
  rg -n "Error|ERROR|does not exist|Cannot|Unhandled|exception|not found" "$SRC" || true
  echo

  echo "STEP 4 — Final classification"
  if rg -q "CLASSIFICATION: TASKS_ROUTE_SCHEMA_ALIGNED" "$SRC"; then
    echo "STATUS: REFRESH_PATH_RECOVERED"
  else
    echo "STATUS: MORE_REVIEW_NEEDED"
  fi
  echo

  echo "STEP 5 — Immediate next action"
  echo "- Hard refresh the browser on http://localhost:8080/dashboard.html"
  echo "- If the page is still white, capture the browser console error next."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"

#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — LOG READABILITY CONTRACT AUDIT"
echo "────────────────────────────────"

OUT="docs/phase487_log_readability_contract_audit.md"
mkdir -p docs

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

{
  echo "# Phase 487 Log Readability Contract Audit"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Runtime posture"
  echo
  echo '```'
  git status --short
  echo
  docker compose ps
  echo '```'
  echo
  echo "## Live surface checks"
  echo
  echo '```'
  echo "GET /api/logs"
  curl -i -s http://localhost:8080/api/logs | sed -n '1,40p' || true
  echo
  echo "GET /logs"
  curl -i -s http://localhost:8080/logs | sed -n '1,40p' || true
  echo
  echo "GET /api/tasks"
  curl -i -s http://localhost:8080/api/tasks | sed -n '1,120p' || true
  echo '```'
  echo
  echo "## Served UI references"
  echo
  echo '```'
  rg -n 'logs|recent logs|task history|recent tasks|tasks-widget|operator-guidance|log readability|task clarity' \
    public/dashboard.html public/index.html public/bundle.js \
    | sed -n '1,220p' || true
  echo '```'
  echo
  echo "## Backend route ownership"
  echo
  echo '```'
  rg -n 'app\.(get|post|use)\("/api/logs"|app\.(get|post|use)\("/logs"|app\.(get|post|use)\("/api/tasks"|app\.(get|post|use)\("/events/tasks"' \
    server.mjs server \
    | sed -n '1,220p' || true
  echo '```'
  echo
  echo "## Likely diagnosis"
  echo
  echo "- If /api/logs and /logs both 404, log readability is currently a missing surface, not just bad formatting."
  echo "- If /api/tasks is live but logs are absent, task clarity can still be improved via task title/summary rendering without backend mutation."
  echo "- Safe next corridor after this audit: UI-only task clarity/readability improvement using existing /api/tasks data."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"

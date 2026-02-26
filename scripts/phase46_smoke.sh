#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p _diag/phase46
bash scripts/_lib/wait_http.sh "http://127.0.0.1:8080/api/runs" 90
ts="$(date +%Y%m%d-%H%M%S)"
out="_diag/phase46/smoke_${ts}.txt"
{
  echo "GET /api/runs"
  curl -fsS "http://127.0.0.1:8080/api/runs" | head -c 2000 || true
  echo
  echo "GET /api/tasks"
  curl -fsS "http://127.0.0.1:8080/api/tasks" | head -c 2000 || true
  echo
  echo "GET /api/task-events"
  curl -fsS "http://127.0.0.1:8080/api/task-events" | head -c 2000 || true
  echo
  echo "GET /api/health (best-effort)"
  curl -fsS "http://127.0.0.1:8080/api/health" | head -c 2000 || true
  echo
} > "$out"
curl -fsS "http://127.0.0.1:8080/api/runs" >/dev/null

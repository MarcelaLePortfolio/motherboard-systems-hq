#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p _diag/phase46

ts="$(date +%Y%m%d-%H%M%S)"
out="_diag/phase46/probe_${ts}.txt"

# Record status codes without failing the run due to 404/connection churn.
{
  echo "ts=${ts}"
  echo

  for p in / /api /api/runs /api/tasks /api/task-events /api/health; do
    code="$(curl -sS -o /dev/null -w "%{http_code}" "http://127.0.0.1:8080${p}" || echo "000")"
    printf "%-20s %s\n" "$p" "$code"
  done

  echo
  echo "GET / (head, best-effort)"
  curl -sS "http://127.0.0.1:8080/" | head -c 1200 || true
  echo
} > "$out"

printf '%s\n' "$out"

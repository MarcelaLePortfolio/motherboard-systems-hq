#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'ACTION=RESTORE_VISIBLE_MATILDA_DASHBOARD_ACCESS' \
  'FRONTEND_RESTART=NO' \
  'DASHBOARD_SUBMISSION=NO' \
  'OLLAMA_INVOCATION=NO'

if curl -sS --max-time 5 http://localhost:5173/ >/dev/null; then
  printf '%s\n' \
    'FRONTEND_REACHABLE=YES' \
    'DASHBOARD_URL=http://localhost:5173' \
    'DASHBOARD_SHOULD_BE_BROUGHT_BACK_NOW=YES'
  open 'http://localhost:5173'
else
  printf '%s\n' \
    'FRONTEND_REACHABLE=NO' \
    'DASHBOARD_NOT_READY_FOR_SMOKE_TEST=YES' \
    'NEXT_ACTION=CLASSIFY_EXISTING_VITE_LISTENER_BEFORE_ANY_RESTART_OR_SUBMISSION'
  exit 1
fi

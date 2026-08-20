#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

REQUEST='Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.'

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_GATE_COMMIT=8a6a86d2' \
  'ACTION=RUN_ONE_AUTHORIZED_DASHBOARD_VISIBLE_SMOKE_TEST' \
  'DASHBOARD_VISIBLE_SMOKE_TEST_AUTHORIZED=YES' \
  'AUTHORIZED_SMOKE_TEST_COUNT=1' \
  'ADDITIONAL_SMOKE_TESTS_AUTHORIZED=NO' \
  'ADDITIONAL_DIAGNOSTIC_OLLAMA_INVOCATIONS_AUTHORIZED=NO'

if ! lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  nohup npm run dev > /tmp/matilda-smoke-backend.log 2>&1 &
  echo $! > /tmp/matilda-smoke-backend.pid

  for _ in {1..30}; do
    if lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

if ! lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  echo 'BACKEND_READY=NO'
  tail -80 /tmp/matilda-smoke-backend.log 2>/dev/null || true
  exit 1
fi

if ! lsof -nP -iTCP:5173 -sTCP:LISTEN >/dev/null 2>&1; then
  (
    cd client
    nohup npm run dev -- --host 127.0.0.1 > /tmp/matilda-smoke-frontend.log 2>&1 &
    echo $! > /tmp/matilda-smoke-frontend.pid
  )

  for _ in {1..30}; do
    if lsof -nP -iTCP:5173 -sTCP:LISTEN >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

if ! lsof -nP -iTCP:5173 -sTCP:LISTEN >/dev/null 2>&1; then
  echo 'FRONTEND_READY=NO'
  tail -80 /tmp/matilda-smoke-frontend.log 2>/dev/null || true
  exit 1
fi

printf '%s' "$REQUEST" | pbcopy

printf '\n=== RUNTIME READINESS ===\n'
printf '%s\n' \
  'BACKEND_READY=YES' \
  'FRONTEND_READY=YES' \
  'DASHBOARD_URL=http://127.0.0.1:5173' \
  'ORIGINAL_REQUEST_COPIED_TO_CLIPBOARD=YES'

open 'http://127.0.0.1:5173'

printf '\n=== SINGLE AUTHORIZED VISIBLE TEST ===\n'
printf '%s\n' \
  '1. Paste the clipboard contents into the Matilda request field.' \
  '2. Submit the request exactly once.' \
  '3. Do not retry if it fails.' \
  '4. Return the exact visible response or error for classification.'

printf '\n=== AUTHORIZATION BOUNDARY ===\n'
printf '%s\n' \
  'ONE_VISIBLE_SUBMISSION_AUTHORIZED=YES' \
  'SECOND_VISIBLE_SUBMISSION_AUTHORIZED=NO' \
  'PRODUCTION_CHANGE_AUTHORIZED=NO' \
  'ISSUE_RESOLUTION_NOT_YET_DECLARED=YES'

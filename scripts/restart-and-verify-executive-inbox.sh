#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

printf '\n=== STOP CURRENT BACKEND ===\n'
SERVER_PID="$(
  lsof -tiTCP:3000 -sTCP:LISTEN 2>/dev/null || true
)"

if [ -n "$SERVER_PID" ]; then
  kill "$SERVER_PID"
  sleep 2
fi

printf '\n=== START CURRENT BACKEND ===\n'
nohup npx ts-node server/index.ts \
  > /tmp/motherboard-server.log \
  2>&1 &

NEW_SERVER_PID=$!

for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if lsof -tiTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
    break
  fi

  if ! kill -0 "$NEW_SERVER_PID" 2>/dev/null; then
    printf '\nSTOP: backend process exited before opening port 3000.\n'
    cat /tmp/motherboard-server.log
    exit 1
  fi

  sleep 1
done

if ! lsof -tiTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  printf '\nSTOP: backend did not open port 3000.\n'
  cat /tmp/motherboard-server.log
  exit 1
fi

printf '\n=== DIRECT EXECUTIVE INBOX PROBE ===\n'
HTTP_STATUS="$(
  curl -sS \
    -o /tmp/executive-inbox-body.json \
    -w '%{http_code}' \
    'http://localhost:3000/api/approval-requests?project_id=hq'
)"

printf 'HTTP status: %s\n' "$HTTP_STATUS"
cat /tmp/executive-inbox-body.json
printf '\n'

if [ "$HTTP_STATUS" != "200" ]; then
  printf '\nSTOP: Executive Inbox endpoint did not return HTTP 200.\n'
  printf '\n=== BACKEND LOG ===\n'
  cat /tmp/motherboard-server.log
  exit 1
fi

printf '\n=== VITE PROXY PROBE ===\n'
if lsof -tiTCP:5173 -sTCP:LISTEN >/dev/null 2>&1; then
  PROXY_STATUS="$(
    curl -sS \
      -o /tmp/executive-inbox-proxy-body.json \
      -w '%{http_code}' \
      'http://localhost:5173/api/approval-requests?project_id=hq'
  )"

  printf 'HTTP status: %s\n' "$PROXY_STATUS"
  cat /tmp/executive-inbox-proxy-body.json
  printf '\n'

  if [ "$PROXY_STATUS" != "200" ]; then
    printf '\nSTOP: Vite proxy did not return HTTP 200.\n'
    exit 1
  fi
else
  printf 'Vite is not currently listening on port 5173; direct backend verification passed.\n'
fi

printf '\n=== CLIENT BUILD ===\n'
pnpm --prefix client run build

printf '\n=== VERIFICATION COMPLETE ===\n'
printf 'The current backend is running and the Executive Inbox route is reachable.\n'

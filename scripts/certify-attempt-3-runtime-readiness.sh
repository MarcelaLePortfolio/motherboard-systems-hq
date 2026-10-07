#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6bd554a0e"
RUNTIME_LOG="/tmp/motherboard-attempt3-runtime.log"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== FRESH BUILD ==="
npm run build

grep -q \
  'Authoritative current concrete operation for Package Semantics expectedOutcome:' \
  dist/scripts/utils/ollamaChat.js

echo "COMPILED_ATTEMPT_3_GROUNDING_PRESENT=YES"

echo
echo "=== RESTART BACKEND ==="

OLD_PIDS="$(lsof -tiTCP:3000 -sTCP:LISTEN || true)"

if [ -n "$OLD_PIDS" ]; then
  echo "OLD_RUNTIME_PIDS=$OLD_PIDS"
  for pid in $OLD_PIDS; do
    kill "$pid"
  done

  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if ! lsof -tiTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

if lsof -tiTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "FAIL_CLOSED=PORT_3000_STILL_OCCUPIED"
  exit 1
fi

: > "$RUNTIME_LOG"

nohup node dist/server/index.js > "$RUNTIME_LOG" 2>&1 &
NEW_PID=$!

for _ in 1 2 3 4 5 6 7 8 9 10; do
  if lsof -tiTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

LISTENER_PID="$(lsof -tiTCP:3000 -sTCP:LISTEN || true)"

if [ -z "$LISTENER_PID" ]; then
  echo "FAIL_CLOSED=NO_RUNTIME_LISTENER"
  cat "$RUNTIME_LOG"
  exit 1
fi

if [ "$LISTENER_PID" != "$NEW_PID" ]; then
  echo "FAIL_CLOSED=UNEXPECTED_RUNTIME_PID"
  echo "STARTED_PID=$NEW_PID"
  echo "LISTENER_PID=$LISTENER_PID"
  exit 1
fi

grep -q 'Server listening on port 3000' "$RUNTIME_LOG"

echo
echo "=== CERTIFICATION ==="
echo "NEW_RUNTIME_PID=$NEW_PID"
echo "LISTENER_PID=$LISTENER_PID"
echo "RUNTIME_STARTUP=PASS"
echo "FRESH_ATTEMPT_3_RUNTIME_CERTIFIED=YES"
echo "DOGFOOD_PERFORMED=NO"
echo "DOGFOOD_COUNT_AFTER_ATTEMPT_3=0"
echo
echo "NEXT_ACTION=SINGLE_CONTROLLED_LIVE_DOGFOOD"
echo "REQUEST=hi matilda, let's start by making changes the frontend. i want to remove the 'packages' tab from the sidebar while preserving all underlying package runtime functionality and authority."

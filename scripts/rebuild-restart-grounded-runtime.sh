#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="98cd474a1"
LOG="/tmp/motherboard-grounded-runtime.log"
PIDFILE="/tmp/motherboard-grounded-runtime.pid"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "GROUNDING_FUNCTIONAL_COMMIT=aa02ffe7b"
echo "ATTEMPT_2_COMPLETE=YES"
echo "ATTEMPT_3_REQUIRED=NO"
echo "LIVE_DOGFOOD=NO"

echo
echo "=== FRESH BUILD ==="
npm run build

echo
echo "=== COMPILED GROUNDING CERTIFICATION ==="
grep -R -q \
  'expectedOutcome must preserve the operation and direction established by the current user request' \
  dist

grep -R -q \
  'Treat preservation requirements as constraints on the requested operation' \
  dist

echo "COMPILED_GROUNDING_PRESENT=YES"

echo
echo "=== CURRENT PORT 3000 OWNER ==="
CURRENT_PID="$(lsof -tiTCP:3000 -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"

if test -n "$CURRENT_PID"; then
  CURRENT_COMMAND="$(ps -p "$CURRENT_PID" -o command= || true)"
  echo "CURRENT_PID=$CURRENT_PID"
  echo "CURRENT_COMMAND=$CURRENT_COMMAND"

  case "$CURRENT_COMMAND" in
    *"node dist/server/index.js"*)
      kill "$CURRENT_PID"

      for _ in 1 2 3 4 5 6 7 8 9 10; do
        if ! kill -0 "$CURRENT_PID" 2>/dev/null; then
          break
        fi
        sleep 1
      done

      if kill -0 "$CURRENT_PID" 2>/dev/null; then
        echo "OLD_RUNTIME_DID_NOT_STOP=YES"
        exit 1
      fi

      echo "OLD_RUNTIME_STOPPED=YES"
      ;;
    *)
      echo "PORT_3000_OWNER_NOT_RECOGNIZED=YES"
      echo "REFUSING_TO_KILL_UNRELATED_PROCESS=YES"
      exit 1
      ;;
  esac
else
  echo "CURRENT_PID=NONE"
fi

echo
echo "=== START FRESH BACKEND ==="
: > "$LOG"
nohup node dist/server/index.js > "$LOG" 2>&1 &
NEW_PID=$!
echo "$NEW_PID" > "$PIDFILE"

sleep 3

kill -0 "$NEW_PID"
LISTENER_PID="$(lsof -tiTCP:3000 -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
test "$LISTENER_PID" = "$NEW_PID"

echo "NEW_RUNTIME_PID=$NEW_PID"
echo "PORT_3000_LISTENER_PID=$LISTENER_PID"

echo
echo "=== STARTUP LOG ==="
cat "$LOG"

if grep -Eiq '(^|[^a-z])(error|fatal|uncaught|EADDRINUSE)([^a-z]|$)' "$LOG"; then
  echo "IMMEDIATE_RUNTIME_ERROR_DETECTED=YES"
  exit 1
fi

echo
echo "FRESH_RUNTIME_CERTIFIED=YES"
echo "COMPILED_GROUNDING_PRESENT=YES"
echo "LIVE_DOGFOOD_PERFORMED=NO"
echo "NEXT_ACTION=SINGLE_CONTROLLED_LIVE_DOGFOOD"

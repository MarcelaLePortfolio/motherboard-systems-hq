#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="c74d6f200"
PORT="3000"
LOG="/tmp/motherboard-approved-package-runtime-restart.log"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

OLD_PID="$(lsof -tiTCP:${PORT} -sTCP:LISTEN | head -1 || true)"
test -n "$OLD_PID"

OLD_CWD="$(lsof -a -p "$OLD_PID" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p')"
test "$OLD_CWD" = "$(pwd)"

echo "OLD_PID=$OLD_PID"
echo "OLD_CWD=$OLD_CWD"

kill "$OLD_PID"

for _ in $(seq 1 20); do
  if ! kill -0 "$OLD_PID" 2>/dev/null; then
    break
  fi
  sleep 0.25
done

if kill -0 "$OLD_PID" 2>/dev/null; then
  echo "OLD_RUNTIME_DID_NOT_STOP=YES"
  exit 1
fi

nohup node dist/server/index.js > "$LOG" 2>&1 &
NEW_PID=$!

for _ in $(seq 1 40); do
  if lsof -tiTCP:${PORT} -sTCP:LISTEN >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done

LISTENER_PID="$(lsof -tiTCP:${PORT} -sTCP:LISTEN | head -1 || true)"
test -n "$LISTENER_PID"

echo "NEW_PID=$NEW_PID"
echo "LISTENER_PID=$LISTENER_PID"

echo
echo "=== LIVE CANONICAL PACKAGE RESPONSE ==="
RESPONSE="$(curl -sS "http://localhost:${PORT}/api/canonical-packages?project_id=hq")"
printf '%s\n' "$RESPONSE"

echo
echo "=== DELEGATION PROJECTION CHECK ==="
printf '%s\n' "$RESPONSE" | grep -q '"delegation"'
echo "LIVE_PAYLOAD_CONTAINS_DELEGATION_PROJECTION=YES"

echo
echo "=== SERVER LOG ==="
cat "$LOG" || true

echo
echo "RUNTIME_RESTARTED=YES"
echo "PRODUCT_CODE_MUTATED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RETEST_APPROVED_ITEM_IN_BROWSER"

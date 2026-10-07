#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="a788761e1"
EXPECTED_PID="59375"
LOG="/tmp/motherboard-grounded-runtime.log"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

LISTENER_PID="$(lsof -tiTCP:3000 -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
test "$LISTENER_PID" = "$EXPECTED_PID"
kill -0 "$EXPECTED_PID"

COMMAND="$(ps -p "$EXPECTED_PID" -o command=)"
case "$COMMAND" in
  *"node dist/server/index.js"*) ;;
  *)
    echo "EXPECTED_RUNTIME_NOT_PRESENT=YES"
    exit 1
    ;;
esac

grep -R -q \
  'expectedOutcome must preserve the operation and direction established by the current user request' \
  dist

grep -R -q \
  'Treat preservation requirements as constraints on the requested operation' \
  dist

if grep -Eiq '(^|[^a-z])(error|fatal|uncaught|EADDRINUSE)([^a-z]|$)' "$LOG"; then
  echo "PRE_DOGFOOD_RUNTIME_ERROR_DETECTED=YES"
  exit 1
fi

echo "FRESH_RUNTIME_CERTIFIED=YES"
echo "GROUNDING_PRESENT_IN_RUNTIME=YES"
echo "ATTEMPT_2_COMPLETE=YES"
echo "ATTEMPT_3_REQUIRED=NO"
echo "DOGFOOD_COUNT_THIS_RUNTIME=0"

echo
echo "=== SUBMIT THIS EXACT REQUEST ONCE ==="
echo "hi matilda, let's start by making changes the frontend. i want to remove the 'packages' tab from the sidebar while preserving all underlying package runtime functionality and authority."

echo
echo "DO_NOT_RETRY_ON_FAILURE=YES"
echo "NEXT_ACTION=PASTE_MATILDA_RESPONSE_AND_RUNTIME_LOG"

git add -- scripts/prepare-single-grounding-dogfood.sh
git commit -m "Prepare single package semantics grounding dogfood"
git push origin "$BRANCH"

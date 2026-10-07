#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="31fae59ee"
RUNTIME_LOG="/tmp/motherboard-attempt3-runtime.log"

echo "=== DOGFOOD PREFLIGHT DIAGNOSIS ==="
echo "DOGFOOD_SUBMISSION_PERFORMED=NO"
echo "DOGFOOD_COUNT=0"

echo
echo "BRANCH_ACTUAL=$(git rev-parse --abbrev-ref HEAD)"
echo "BRANCH_EXPECTED=$BRANCH"
echo "HEAD_ACTUAL=$(git rev-parse --short=9 HEAD)"
echo "HEAD_EXPECTED=$EXPECTED_HEAD"

git fetch origin "$BRANCH"

echo "LOCAL_HEAD=$(git rev-parse HEAD)"
echo "REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")"

echo
echo "=== RUNTIME ==="
LISTENER_PID="$(lsof -tiTCP:3000 -sTCP:LISTEN || true)"
echo "LISTENER_PID=${LISTENER_PID:-NONE}"
ps -p "${LISTENER_PID:-0}" -o pid=,etime=,command= 2>/dev/null || true

echo
echo "=== COMPILED GROUNDING ==="
if grep -q \
  'Authoritative current concrete operation for Package Semantics expectedOutcome:' \
  dist/scripts/utils/ollamaChat.js; then
  echo "COMPILED_ATTEMPT_3_GROUNDING_PRESENT=YES"
else
  echo "COMPILED_ATTEMPT_3_GROUNDING_PRESENT=NO"
fi

echo
echo "=== RUNTIME LOG ==="
if [ -f "$RUNTIME_LOG" ]; then
  echo "RUNTIME_LOG_PRESENT=YES"
  grep -n 'Server listening on port 3000' "$RUNTIME_LOG" || true
  tail -n 40 "$RUNTIME_LOG"
else
  echo "RUNTIME_LOG_PRESENT=NO"
fi

echo
echo "=== PREFLIGHT SCRIPT TRACE ==="
bash -x scripts/prepare-single-attempt-3-dogfood.sh </dev/null 2>&1 || true

echo
echo "DOGFOOD_REQUEST_NOT_SUBMITTED=YES"
echo "NEXT_ACTION=CLASSIFY_PREFLIGHT_EXIT_BEFORE_DOGFOOD"

#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_RUNTIME_PID="61897"
RUNTIME_LOG="/tmp/motherboard-attempt3-runtime.log"
CAPTURE="/tmp/motherboard-attempt3-dogfood-result.log"
REQUEST="hi matilda, let's start by making changes the frontend. i want to remove the 'packages' tab from the sidebar while preserving all underlying package runtime functionality and authority."

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

git fetch origin "$BRANCH"

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "origin/$BRANCH")"
test "$LOCAL_HEAD" = "$REMOTE_HEAD"

LISTENER_PID="$(lsof -tiTCP:3000 -sTCP:LISTEN || true)"
test "$LISTENER_PID" = "$EXPECTED_RUNTIME_PID"

grep -q \
  'Authoritative current concrete operation for Package Semantics expectedOutcome:' \
  dist/scripts/utils/ollamaChat.js

grep -q 'Server listening on port 3000' "$RUNTIME_LOG"

: > "$CAPTURE"

echo "=== SINGLE CONTROLLED ATTEMPT 3 DOGFOOD ==="
echo "REPOSITORY_REMOTE_CONVERGED=YES"
echo "FRESH_RUNTIME_CERTIFIED=YES"
echo "RUNTIME_PID=$LISTENER_PID"
echo "COMPILED_ATTEMPT_3_GROUNDING_PRESENT=YES"
echo "DOGFOOD_COUNT_BEFORE=0"
echo "MAX_DOGFOOD_SUBMISSIONS=1"
echo
echo "Submit this exact request ONCE in Matilda:"
echo
echo "$REQUEST"
echo
echo "Do not retry if Matilda returns an error."
echo "After Matilda responds, return to this terminal and press ENTER once."
read -r

tail -n 160 "$RUNTIME_LOG" | tee "$CAPTURE"

echo
echo "=== RESULT CLASSIFICATION ==="

if grep -q \
  'Ollama response failed current-request Package Semantics fidelity for expectedOutcome' \
  "$CAPTURE"; then
  echo "EXPECTED_OUTCOME_FIDELITY_FAILURE=YES"
else
  echo "EXPECTED_OUTCOME_FIDELITY_FAILURE=NO"
fi

if grep -q '\[Ollama expectedOutcome fidelity diagnostic\]' "$CAPTURE"; then
  echo "EXPECTED_OUTCOME_DIAGNOSTIC=YES"
else
  echo "EXPECTED_OUTCOME_DIAGNOSTIC=NO"
fi

if grep -q 'Conversational response failed' "$CAPTURE"; then
  echo "CONVERSATIONAL_RESPONSE_FAILURE=YES"
else
  echo "CONVERSATIONAL_RESPONSE_FAILURE=NO"
fi

echo
echo "DOGFOOD_COUNT_AFTER=1"
echo "DOGFOOD_RETRY_PERFORMED=NO"
echo "CAPTURE=$CAPTURE"
echo "NEXT_ACTION=CLASSIFY_SINGLE_RESULT_BEFORE_ANY_FURTHER_CHANGE"

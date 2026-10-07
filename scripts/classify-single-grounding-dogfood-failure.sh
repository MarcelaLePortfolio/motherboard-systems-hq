#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d44362685"
CAPTURE="/tmp/motherboard-grounding-dogfood-result.log"
LOG="/tmp/motherboard-grounded-runtime.log"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "DOGFOOD_RESULT=503_SERVICE_UNAVAILABLE"
echo "DOGFOOD_COUNT=1"
echo "DOGFOOD_RETRY_AUTHORIZED=NO"
echo "IMPLEMENTATION_CHANGE_JUSTIFIED=NOT_YET"

if test ! -s "$CAPTURE"; then
  echo "CAPTURE_FILE_UNAVAILABLE_OR_EMPTY=YES"
  echo "USING_CURRENT_RUNTIME_LOG_FOR_CLASSIFICATION=YES"
  tail -n 160 "$LOG" > "$CAPTURE"
fi

echo
echo "=== CAPTURED RUNTIME EVIDENCE ==="
cat "$CAPTURE"

echo
echo "=== CLASSIFICATION ==="

if grep -q 'Ollama response failed current-request Package Semantics fidelity for expectedOutcome' "$CAPTURE"; then
  echo "EXPECTED_OUTCOME_FIDELITY_FAILURE_OBSERVED=YES"
else
  echo "EXPECTED_OUTCOME_FIDELITY_FAILURE_OBSERVED=NO"
fi

if grep -q '\[Ollama expectedOutcome fidelity diagnostic\]' "$CAPTURE"; then
  echo "EXPECTED_OUTCOME_DIAGNOSTIC_OBSERVED=YES"
else
  echo "EXPECTED_OUTCOME_DIAGNOSTIC_OBSERVED=NO"
fi

if grep -q 'Conversational response failed' "$CAPTURE"; then
  echo "CONVERSATIONAL_RESPONSE_FAILURE_OBSERVED=YES"
else
  echo "CONVERSATIONAL_RESPONSE_FAILURE_OBSERVED=NO"
fi

echo
echo "=== RELEVANT FAILURE LINES ==="
grep -E \
  'Ollama expectedOutcome fidelity diagnostic|Package Semantics fidelity|Conversational response failed|503|Error:' \
  "$CAPTURE" || true

echo
echo "DOGFOOD_RETRY_PERFORMED=NO"
echo "NEXT_ACTION=CLASSIFY_ROOT_CAUSE_BEFORE_ANY_FURTHER_IMPLEMENTATION"

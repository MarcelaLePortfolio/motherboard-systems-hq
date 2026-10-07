#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
CAPTURE="/tmp/motherboard-attempt3-dogfood-result.log"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== ATTEMPT 3 LIVE RESULT ==="
echo "DOGFOOD_COUNT=1"
echo "DOGFOOD_RETRY_PERFORMED=NO"
echo "ATTEMPT_3_STATIC_VALIDATION=PASS"
echo "ATTEMPT_3_LIVE_VALIDATION=FAIL"

test -s "$CAPTURE"

grep -q \
  'Ollama response requires non-null Package Semantics with a non-empty expectedOutcome' \
  "$CAPTURE"

if grep -q \
  'Ollama response failed current-request Package Semantics fidelity for expectedOutcome' \
  "$CAPTURE"; then
  echo "FIDELITY_FAILURE=YES"
else
  echo "FIDELITY_FAILURE=NO"
fi

if grep -q '\[Ollama expectedOutcome fidelity diagnostic\]' "$CAPTURE"; then
  echo "FIDELITY_DIAGNOSTIC=YES"
else
  echo "FIDELITY_DIAGNOSTIC=NO"
fi

echo "REQUIRED_PACKAGE_SEMANTICS_FAILURE=YES"
echo "FAILURE_BOUNDARY=MISSING_OR_NULL_MODEL_AUTHORED_PACKAGE_SEMANTICS_EXPECTED_OUTCOME"
echo "PRIOR_DIRECTION_INVERSION_OBSERVED=NO"
echo "ATTEMPT_3_SUCCESS=NO"

echo
echo "=== EXACT REQUIRED-SEMANTICS GUARD ==="
grep -n -A35 -B20 \
  'Ollama response requires non-null Package Semantics with a non-empty expectedOutcome' \
  "$TARGET"

echo
echo "=== PACKAGE SEMANTICS PARSE / EXTRACTION REFERENCES ==="
grep -nE \
  'packageSemantics|parsedResponse|JSON\.parse|safeParse|expectedOutcome' \
  "$TARGET" | tail -n 180

echo
echo "=== ATTEMPT HISTORY ==="
echo "ATTEMPT_1=FAILED_BEFORE_TARGET_MUTATION_BAD_PROMPT_ANCHOR"
echo "ATTEMPT_2=LIVE_FAILURE_DIRECTION_AND_SUBJECT_SUBSTITUTION"
echo "ATTEMPT_3=LIVE_FAILURE_MISSING_OR_NULL_REQUIRED_PACKAGE_SEMANTICS"
echo "CONSECUTIVE_FAILED_GROUNDING_HYPOTHESES_LIMIT_REACHED=YES"

echo
echo "=== CONTROL DECISION ==="
echo "DOGFOOD_RETRY_AUTHORIZED=NO"
echo "FURTHER_LAYERED_GROUNDING_FIX_AUTHORIZED=NO"
echo "SOURCE_MUTATION_PERFORMED=NO"
echo "NEXT_ACTION=REASSESS_FAILURE_CLASS_AND_REVERT_TO_LAST_KNOWN_STABLE_BOUNDARY_IF_NO_DISTINCT_CAUSE_IS_ESTABLISHED"

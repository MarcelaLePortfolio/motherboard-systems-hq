#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e9bc04ccc"
TARGET="scripts/utils/ollamaChat.ts"
LOG="/tmp/motherboard-grounded-runtime.log"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== DECISIVE LIVE EVIDENCE ==="

grep -F -A5 \
  '[Ollama expectedOutcome fidelity diagnostic]' \
  "$LOG" | tail -n 6

echo
echo "REQUESTED_OPERATION=remove"
echo "REQUESTED_SUBJECT=packages tab"
echo "PRESERVATION_CONSTRAINT=underlying package runtime functionality and authority"
echo "MODEL_GENERATED_OPERATION=restore"
echo "MODEL_GENERATED_SUBJECT=Canonical Package visibility read-only API / Approvals / Executive Inbox"
echo "FIDELITY_GUARD_RESULT=CORRECT_FAIL_CLOSED"

echo
echo "=== ATTEMPT CLASSIFICATION ==="
echo "ATTEMPT_2_STATIC_VALIDATION=PASS"
echo "ATTEMPT_2_LIVE_VALIDATION=FAIL"
echo "ATTEMPT_2_FAILURE_ESTABLISHED=YES"
echo "FAILURE_CLASS=UPSTREAM_MODEL_GENERATION_DIRECTION_AND_SUBJECT_SUBSTITUTION"
echo "GROUNDING_PROMPT_IN_RUNTIME=YES"
echo "GROUNDING_PROMPT_SUFFICIENT=NO"
echo "FIDELITY_GUARD_DEFECT_ESTABLISHED=NO"
echo "FIDELITY_GUARD_CHANGE_JUSTIFIED=NO"
echo "PARSER_CHANGE_JUSTIFIED=NO"
echo "SCHEMA_CHANGE_JUSTIFIED=NO"
echo "AUTHORITY_CHANGE_JUSTIFIED=NO"
echo "LIVE_RETRY_JUSTIFIED=NO"

echo
echo "=== CURRENT GROUNDING INSTRUCTIONS ==="
grep -n -A4 -B3 \
  'expectedOutcome must preserve the operation and direction established by the current user request' \
  "$TARGET"

echo
echo "=== NEXT BOUNDARY ==="
echo "ATTEMPT_3_REQUIRED=YES"
echo "ATTEMPT_3_NOT_AUTHORIZED=YES"
echo "NEXT_HYPOTHESIS=DETERMINISTIC_CURRENT_REQUEST_GROUNDING_BEFORE_MODEL_GENERATION"
echo "REQUIREMENT=Prevent unrelated historical or retrieved package concepts from replacing the current concrete operation and subject in model-authored expectedOutcome."
echo "NO_SOURCE_MUTATION_PERFORMED=YES"
echo "NO_DOGFOOD_RETRY_PERFORMED=YES"

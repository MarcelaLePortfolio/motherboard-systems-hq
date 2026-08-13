#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CURRENT PHASE 3 CORRIDOR 5 — REGRESSION VALIDATION RESULT ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor c0d1d5bc HEAD

runner="scripts/run-current-phase-3-existing-regression-validation-set.sh"
test -f "$runner"

echo "=== VERIFY CURRENT REGRESSION RUNNER CONTRACT ==="
grep -q 'REGRESSION_SET_SIZE=7' "$runner"
grep -q 'EXECUTION_POLICY=RUN_EACH_EXISTING_TEST_EXACTLY_ONCE' "$runner"
grep -q 'LIVE_OLLAMA_INVOCATIONS=NONE' "$runner"
grep -q 'REGRESSION_SET_RESULT=PASS' "$runner"

echo "CURRENT_REGRESSION_RUNNER_CONTRACT=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION BASELINE REMAINS UNCHANGED ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

PHASE=
PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE

CORRIDOR=
PRODUCTION_REGRESSION_VALIDATION

CURRENT_REGRESSION_SET_EXECUTED=
7

CURRENT_REGRESSION_SET_PASSED=
7

CURRENT_REGRESSION_SET_FAILED=
0

REGRESSION_SET_RESULT=
PASS

PRODUCTION_RUNTIME_REGRESSION=
NOT_ESTABLISHED_ON_SELECTED_DETERMINISTIC_SURFACE

KNOWN_PRODUCTION_GENERATION_INSTABILITY=
REMAINS_ESTABLISHED_AND_SEPARATE

INTERPRETATION=
All seven selected deterministic repository-supported regression tests passed.

The current Phase 3 validation work therefore does not establish a repository
or production-runtime regression across this selected deterministic surface.

This result does not establish production generation stability and does not
override the separately observed unseeded generation instability.

FAIL_CLOSED_CONTRACT=
PRESERVED

SINGLE_OLLAMA_INVOCATION=
PRESERVED

PRODUCTION_GENERATION_POLICY=
UNCHANGED_UNCONFIGURED_UNSEEDED

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

PRODUCTION_REGRESSION_VALIDATION=
COMPLETE

NEXT_CORRIDOR=
GENERATION_STABILITY_CLOSURE

NEXT_ACTION=
RUN_DR_BEFORE_CORRIDOR_6
MAP

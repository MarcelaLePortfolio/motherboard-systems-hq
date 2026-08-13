#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN CURRENT PHASE 3 CORRIDOR 5 — EXISTING REGRESSION VALIDATION SET ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 02d34c43 HEAD

tests=(
  scripts/validate-adaptive-detail-mixed-content-criteria.test.ts
  scripts/validate-source-excerpt-first-live-contract.test.ts
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts
)

echo "REGRESSION_SET_SIZE=7"
echo "EXECUTION_POLICY=RUN_EACH_EXISTING_TEST_EXACTLY_ONCE"
echo "LIVE_OLLAMA_INVOCATIONS=NONE"
echo "PRODUCTION_CHANGE=NONE"

pass_count=0
fail_count=0

for test_file in "${tests[@]}"; do
  echo
  echo "=== RUN $test_file ==="

  set +e
  npx tsx "$test_file"
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    echo "RESULT=PASS"
    pass_count=$((pass_count + 1))
  else
    echo "RESULT=FAIL"
    echo "EXIT_CODE=$rc"
    fail_count=$((fail_count + 1))
  fi
done

echo
echo "=== REGRESSION VALIDATION SUMMARY ==="
echo "EXECUTED_TESTS=7"
echo "PASS_COUNT=$pass_count"
echo "FAIL_COUNT=$fail_count"

if [[ "$fail_count" -ne 0 ]]; then
  echo "REGRESSION_SET_RESULT=FAIL"
  echo "NEXT_ACTION=CLASSIFY_DETERMINISTIC_TEST_FAILURE_BEFORE_ANY_FIX"
  exit 2
fi

echo "REGRESSION_SET_RESULT=PASS"
echo "PRODUCTION_RUNTIME_REGRESSION=NOT_ESTABLISHED_ON_SELECTED_DETERMINISTIC_SURFACE"
echo "KNOWN_PRODUCTION_GENERATION_INSTABILITY=REMAINS_SEPARATE"
echo "PRODUCTION_GENERATION_POLICY=UNCHANGED_UNCONFIGURED_UNSEEDED"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=CLASSIFY_CURRENT_PHASE_3_REGRESSION_VALIDATION_RESULT"

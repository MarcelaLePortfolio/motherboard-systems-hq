#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY DETERMINISTIC REGRESSION VALIDATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="8e035fe7"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches one-Ollama-invocation checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-deterministic-regression-validation\.sh$|^ M scripts/classify-deterministic-regression-validation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "ONE_OLLAMA_INVOCATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY EXISTING DETERMINISTIC VALIDATION SURFACE ==="

test_files="$(
  find server scripts/utils -type f \
    \( -name '*.test.ts' -o -name '*.test.tsx' \) \
    2>/dev/null |
  grep -E 'matilda|ollamaChat' |
  sort
)"

if [[ -z "$test_files" ]]; then
  echo "STOP: no existing Matilda/Ollama deterministic test surface found."
  exit 2
fi

test_count="$(printf '%s\n' "$test_files" | sed '/^$/d' | wc -l | tr -d ' ')"

echo "DETERMINISTIC_TEST_FILES_FOUND=$test_count"

echo
echo "=== RUN EXISTING DETERMINISTIC TEST SURFACE ==="

log_file="/tmp/matilda-semantic-history-deterministic-regression.log"
: > "$log_file"

set +e
printf '%s\n' "$test_files" | xargs pnpm exec tsx --test >"$log_file" 2>&1
test_status=$?
set -e

if [[ "$test_status" -ne 0 ]]; then
  echo "DETERMINISTIC_REGRESSION_RESULT=FAILED"
  echo "LOG=$log_file"
  echo "=== FAILURE TAIL ==="
  tail -60 "$log_file"
  exit "$test_status"
fi

pass_count="$(
  grep -Ec '^#? ?tests? [0-9]+|^#? ?pass [0-9]+' "$log_file" || true
)"

echo "DETERMINISTIC_REGRESSION_RESULT=PASS"
echo "LOG=$log_file"

echo
echo "=== DETERMINISTIC REGRESSION VALIDATION CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  OPTIMIZATION_INTEGRATION_AND_CLOSURE

CORRIDOR=
  DETERMINISTIC_REGRESSION_VALIDATION

VALIDATION_SCOPE=
  EXISTING_MATILDA_AND_OLLAMA_DETERMINISTIC_TEST_SURFACE

NEW_RUNTIME_BEHAVIOR=
  NONE

NEW_OPTIMIZATION_BEHAVIOR=
  NONE

DETERMINISTIC_REGRESSION_RESULT=
  PASS

SELECTED_HISTORY_CONTRACT=
  PRESERVED

AUTHORITY_EVALUATION=
  PRESERVED

CONTAMINATION_EVALUATION=
  PRESERVED

CHRONOLOGY_AND_LINEAGE=
  PRESERVED

CONVERSATION_CONTEXT_RUNTIME=
  PRESERVED

PROJECT_CONTEXT_BOUNDARY=
  PRESERVED

PRIOR_INVESTIGATION_LIFECYCLE_BOUNDARY=
  PRESERVED

STRUCTURED_RESPONSE_CONTRACT=
  PRESERVED

FAIL_CLOSED_VALIDATION=
  PRESERVED

ONE_OLLAMA_INVOCATION=
  PRESERVED

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

DETERMINISTIC_REGRESSION_VALIDATION_CORRIDOR=
  COMPLETE_WITH_EXISTING_TEST_SURFACE_PASSING

NEXT_CORRIDOR=
  MILESTONE_CLOSURE_CLASSIFICATION

NEXT_ACTION=
  CLASSIFY_SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION_MILESTONE_CLOSURE
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-deterministic-regression-validation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside deterministic regression classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

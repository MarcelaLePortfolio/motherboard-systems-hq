#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CURRENT PHASE 3 CORRIDOR 5 — REGRESSION VALIDATION SET CURRENTNESS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 0468b07b HEAD

boundary="scripts/classify-phase-3-production-regression-validation-boundary.sh"
validation_set="scripts/classify-phase-3-existing-regression-validation-set.sh"

test -f "$boundary"
test -f "$validation_set"

echo "=== VERIFY CURRENT PREDECESSOR ==="
current_single="scripts/classify-current-phase-3-single-ollama-invocation-preservation.sh"
test -f "$current_single"
grep -q 'SINGLE_OLLAMA_INVOCATION_PRESERVATION=' "$current_single"
grep -q 'COMPLETE' "$current_single"
echo "SINGLE_OLLAMA_INVOCATION_PREDECESSOR=COMPLETE"

echo
echo "=== VERIFY EXISTING REGRESSION SET FILES ==="

tests=(
  scripts/validate-adaptive-detail-mixed-content-criteria.test.ts
  scripts/validate-source-excerpt-first-live-contract.test.ts
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts
)

for file in "${tests[@]}"; do
  test -f "$file"
  echo "PRESENT=$file"
done

echo
echo "=== VERIFY NON-LIVE / NON-OLLAMA CHARACTER ==="

for file in "${tests[@]}"; do
  if grep -qE \
    'ollamaChat\(|/api/generate|validationGenerationSeed|OLLAMA_BASE_URL|OLLAMA_MODEL' \
    "$file"
  then
    echo "STOP: regression candidate is not safely classified as non-live/non-Ollama: $file"
    exit 2
  fi
done

echo "NON_LIVE_NON_OLLAMA_REGRESSION_SET=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION BASELINE ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

echo "PRODUCTION_GENERATION_POLICY=UNCHANGED_UNCONFIGURED_UNSEEDED"
echo "PRODUCTION_OLLAMA_INVOCATION_COUNT=ONE"

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=PRODUCTION_REGRESSION_VALIDATION

ADMISSIBLE_CURRENT_REGRESSION_SET=
scripts/validate-adaptive-detail-mixed-content-criteria.test.ts
scripts/validate-source-excerpt-first-live-contract.test.ts
scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts
scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts
scripts/validate-investigation-lifecycle-prior-context-transport.test.ts
scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts
scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

REGRESSION_SET_SIZE=
7
REGRESSION_SET_CHARACTER=
DETERMINISTIC
NON_LIVE
NON_SEEDED
NO_OLLAMA_INVOCATION
EXECUTION_POLICY=
RUN_EACH_EXISTING_TEST_EXACTLY_ONCE
LIVE_UNSEEDED_GENERATION_REPETITION=
NOT_REQUIRED_FOR_THIS_CORRIDOR
NEW_REGRESSION_FIXTURE_REQUIRED=
NO
KNOWN_PRODUCTION_GENERATION_INSTABILITY=
SEPARATE_AND_ALREADY_ESTABLISHED
PRODUCTION_CHANGE=
NONE
IMPLEMENTATION_AUTHORIZED=
NO
REGRESSION_VALIDATION_SET_CURRENTNESS=
CURRENT_AND_REUSABLE
CORRIDOR_5_EXECUTION_READINESS=
ESTABLISHED
NEXT_ACTION=
RUN_CURRENT_EXISTING_REGRESSION_VALIDATION_SET
MAP

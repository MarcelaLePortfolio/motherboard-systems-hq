#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY REQUEST-SCOPED VS SHARED GENERATION POLICY BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY SEMANTIC-PRESERVATION DISPOSITION CHECKPOINT ==="
expected_head="a874e63a"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches semantic-preservation disposition checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-request-scoped-vs-shared-generation-policy-boundary\.sh$|^ M scripts/classify-request-scoped-vs-shared-generation-policy-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "SEMANTIC_PRESERVATION_DISPOSITION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING DISPOSITION ==="
grep -nE \
  'DEFER_PRODUCTION_PROMOTION|NOT_READY_FOR_PRODUCTION_PROMOTION|PRODUCTION_SEED_IMPLEMENTATION_AUTHORIZED=|PRODUCTION_GENERATION_POLICY=|CONTINUE_TO_POLICY_OWNERSHIP_AND_CONTROL_BOUNDARY_CLASSIFICATION|CLASSIFY_REQUEST_SCOPED_VS_SHARED_GENERATION_POLICY_BOUNDARY' \
  scripts/classify-generation-control-semantic-preservation-corridor-disposition.sh

echo "GOVERNING_DISPOSITION=CONFIRMED"

echo
echo "=== INSPECT GENERATION CONTROL SEAMS ==="
grep -nE \
  'validationGenerationSeed|options:|seed:|temperature|top_p|top_k|OLLAMA_BASE_URL|model:' \
  scripts/utils/ollamaChat.ts |
  head -220

echo
echo "=== INSPECT PRODUCTION CALL SITE ==="
grep -n -A80 -B20 \
  'ollamaChat(message' \
  server/matilda-chat-workflow.ts

echo
echo "=== INSPECT VALIDATION-ONLY SEED USAGE ==="
grep -RIn \
  'validationGenerationSeed' \
  scripts \
  server \
  --include='*.ts' \
  --include='*.sh' |
  head -240

echo
echo "=== VERIFY PRODUCTION WORKFLOW DOES NOT SUPPLY VALIDATION SEED ==="
if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow now supplies validationGenerationSeed."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT"

echo
echo "=== CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=REQUEST_SCOPED_VS_SHARED_POLICY_BOUNDARY
UNIT=POLICY_OWNERSHIP_CLASSIFICATION

CURRENT_GENERATION_CONTROL_SEAM=
  REQUEST_SCOPED_CONTEXT_INPUT

CURRENT_IMPLEMENTED_CONTROL=
  validationGenerationSeed

CURRENT_CONTROL_OWNERSHIP=
  CALLER_SUPPLIED_PER_INVOCATION

CURRENT_PRODUCTION_USAGE=
  ABSENT

CURRENT_SHARED_POLICY_LAYER=
  NOT_ESTABLISHED

CURRENT_PRODUCTION_DEFAULT_POLICY=
  MODEL_AND_OLLAMA_DEFAULTS

REQUEST_SCOPED_BOUNDARY=
  ESTABLISHED

RATIONALE=
  validationGenerationSeed is carried through the ollamaChat invocation
  context and translated into a request-level Ollama options.seed value only
  when explicitly supplied.

  The production Matilda workflow does not supply validationGenerationSeed.

  Therefore the existing implemented control belongs to a request-scoped
  diagnostic seam rather than an established shared production policy layer.

SHARED_POLICY_BOUNDARY=
  NOT_CURRENTLY_IMPLEMENTED

  No repository evidence establishes a shared generation-policy object,
  application-wide seed configuration, workflow-wide sampling policy, or
  production default override for seed, temperature, top_p, or top_k.

PRODUCTION_POLICY_PROMOTION_REQUIREMENT=
  SEPARATE_EXPLICIT_POLICY_DECISION_REQUIRED

  Promoting any request-scoped diagnostic control into ordinary production
  behavior would create a new policy boundary and cannot be treated as merely
  reusing the existing validation seam.

SEMANTIC_PRESERVATION_DEPENDENCY=
  UNRESOLVED

  Wider semantic preservation has not been established, so even a technically
  available request-scoped control is not eligible for production promotion.

CONTROL_SCOPE_INVARIANT=
  Validation-only request-scoped controls may remain available for bounded
  diagnostics without altering ordinary production semantics.

  Shared or production-wide generation controls require separate ownership,
  authorization, rollback, and semantic-preservation evidence.

REQUEST_SCOPED_DIAGNOSTIC_SEED=
  PRESERVE

SHARED_PRODUCTION_SEED_POLICY=
  DO_NOT_CREATE_YET

SHARED_TEMPERATURE_POLICY=
  DO_NOT_CREATE_YET

SHARED_TOP_P_POLICY=
  DO_NOT_CREATE_YET

SHARED_TOP_K_POLICY=
  DO_NOT_CREATE_YET

PRODUCTION_SEED_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

BOUNDARY_CLASSIFICATION_RESULT=
  REQUEST_SCOPED_DIAGNOSTIC_CONTROL_ESTABLISHED
  SHARED_PRODUCTION_POLICY_NOT_ESTABLISHED

PHASE_2_STATUS=
  CONTINUE_TO_GENERATION_CONTROL_AUTHORIZATION_AND_OWNERSHIP_BOUNDARY

NEXT_ACTION=
  CLASSIFY_GENERATION_CONTROL_AUTHORIZATION_AND_OWNERSHIP_BOUNDARY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-request-scoped-vs-shared-generation-policy-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-request-scoped-vs-shared-generation-policy-boundary.sh
git diff --cached --check
git commit -m "Classify request scoped generation policy boundary"
git push

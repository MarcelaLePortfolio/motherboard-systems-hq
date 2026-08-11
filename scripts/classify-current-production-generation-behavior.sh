#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CURRENT PRODUCTION GENERATION BEHAVIOR ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY EXPECTED CHECKPOINT ==="
if [[ "$(git rev-parse --short=8 HEAD)" != "e0b651ee" ]]; then
  echo "STOP: HEAD no longer matches reconciliation checkpoint e0b651ee."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-current-production-generation-behavior\.sh$|^ M scripts/classify-current-production-generation-behavior\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_RECONCILIATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION GENERATION PATH ==="
grep -nE 'await ollamaChat\(message' server/matilda-chat-workflow.ts
grep -nE 'OLLAMA_BASE_URL|/api/generate' scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY PRODUCTION WORKFLOW DOES NOT SUPPLY GENERATION POLICY ==="
if grep -nE 'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow currently supplies an explicit generation control."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_EXPLICIT_GENERATION_CONTROL=ABSENT"

echo
echo "=== VERIFY VALIDATION-ONLY SEED SEAM ==="
grep -nE 'validationGenerationSeed|seed: context\.validationGenerationSeed' \
  scripts/utils/ollamaChat.ts

echo "VALIDATION_ONLY_SEED_SEAM=CONFIRMED"

echo
echo "=== VERIFY PRIOR UNSEEDED VARIANCE EVIDENCE ==="
grep -nE \
  'multiple other identical unseeded invocations succeeded|ordinary unseeded model behavior remains variable|unseeded model-authored support provenance may occasionally fail closed' \
  scripts/classify-adaptive-detail-stability-from-seeded-evidence.sh

grep -nE \
  'Multiple unseeded runs produced that intended behavior|One documented unseeded run instead authored an invalid|remaining unseeded variance therefore belongs to a separate generation' \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh

echo "PRIOR_UNSEEDED_VARIANCE_EVIDENCE=CONFIRMED"

echo
echo "=== VERIFY SEEDED DIAGNOSTIC BOUNDARY ==="
grep -nE \
  'Seeded evidence does not prove unseeded production reliability|production seed would alter shared Conversation Engine generation policy|temperature/top_p/top_k policy belongs to Conversation Engine' \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh

echo "SEEDED_DIAGNOSTIC_BOUNDARY=CONFIRMED"

echo
echo "=== VERIFY FAIL-CLOSED STRUCTURED RESPONSE SURFACE ==="
grep -nE \
  'malformed structured response JSON|empty conversational reply|durableInterpretation|supportSourceReferences|investigationLifecycle' \
  scripts/utils/ollamaChat.ts | head -40

echo "FAIL_CLOSED_STRUCTURED_RESPONSE_SURFACE=CONFIRMED"

echo
echo "=== CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR=CURRENT_PRODUCTION_GENERATION_BEHAVIOR_RECONCILIATION

CURRENT_PRODUCTION_GENERATION_PATH=
  server/matilda-chat-workflow.ts
  -> ollamaChat(message, context)
  -> scripts/utils/ollamaChat.ts
  -> single Ollama /api/generate invocation

CURRENT_PRODUCTION_GENERATION_POLICY=
  No explicit production validationGenerationSeed is supplied.
  No explicit production temperature policy is supplied by matilda-chat-workflow.ts.
  No explicit production top_p policy is supplied by matilda-chat-workflow.ts.
  No explicit production top_k policy is supplied by matilda-chat-workflow.ts.

VALIDATION_ONLY_CONTROL=
  ollamaChat supports an optional request-scoped validationGenerationSeed.
  When supplied, that value reaches options.seed on the existing Ollama request.
  This seam is diagnostic and is not supplied by the production workflow.

EXISTING_STABILITY_EVIDENCE=
  Repeated identical unseeded invocations have previously produced multiple
  successful intended results and at least one documented invalid semantic
  support-provenance result.

  Therefore ordinary unseeded semantic generation has demonstrated observable
  variance.

  Repeated seeded diagnostic runs previously demonstrated reproducible output
  under the validation-only seed seam.

  Seeded reproducibility does not establish ordinary unseeded production
  reliability.

STRUCTURED_RESPONSE_FAILURE_BOUNDARY=
  The adapter parses one structured JSON response and fails closed on invalid
  required response structure or semantics.

  Therefore generation variance can manifest either as acceptable semantic
  variation or as output that crosses a deterministic contract boundary and
  fails closed.

CURRENT_CLASSIFICATION=
  The repository establishes a real distinction between ordinary unseeded
  production generation and validation-only seeded diagnostics.

  The repository also establishes prior evidence of unseeded semantic variance.

  The repository does not yet establish the frequency, distribution, or
  production-level acceptance significance of that variance across a bounded
  representative repeated-run sample.

  No production generation-policy intervention is yet justified by Corridor 1
  alone.

CORRIDOR_1_RESULT=RECONCILED
IMPLEMENTATION_AUTHORIZED=NO
IMPLEMENTATION_STARTED=NO
PRODUCTION_CHANGE=NONE

NEXT_CORRIDOR=UNSEEDED_SEMANTIC_VARIANCE_CHARACTERIZATION
NEXT_ACTION=DEFINE_BOUNDED_UNSEEDED_VARIANCE_CHARACTERIZATION_CONTRACT
MAP

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-current-production-generation-behavior\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside investigation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-current-production-generation-behavior.sh
git diff --cached --check
git commit -m "Classify current production generation behavior"
git push

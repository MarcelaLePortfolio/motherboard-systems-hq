#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CHECKPOINT EVIDENCE COMPOSITION VALIDATION RECONCILIATION ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY EXPECTED WORKING-TREE SURFACE ==="
allowed='^ M scripts/validate-source-excerpt-first-live\.ts$|^\?\? scripts/classify-phase-1-response-composition-state\.sh$|^\?\? scripts/determine-next-response-composition-corridor\.sh$|^\?\? scripts/investigate-source-excerpt-live-support-source-competition\.sh$|^\?\? scripts/reclassify-phase-1-response-composition-after-evidence-closure\.sh$|^\?\? scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract\.sh$|^\?\? scripts/remove-stale-conversation-support-from-source-excerpt-live-fixture\.sh$|^\?\? scripts/validate-source-excerpt-first-live-contract\.test\.ts$|^\?\? scripts/checkpoint-evidence-composition-validation-reconciliation\.sh$'

unexpected="$(
  git status --porcelain |
  grep -vE "$allowed" ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_WORKING_TREE_SURFACE_CONFIRMED"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VALIDATOR CONTRACT TEST ==="
npx tsx --test \
  scripts/validate-source-excerpt-first-live-contract.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "=== STAGE RECONCILIATION ARTIFACTS ==="
git add \
  scripts/validate-source-excerpt-first-live.ts \
  scripts/validate-source-excerpt-first-live-contract.test.ts \
  scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract.sh \
  scripts/remove-stale-conversation-support-from-source-excerpt-live-fixture.sh \
  scripts/investigate-source-excerpt-live-support-source-competition.sh \
  scripts/determine-next-response-composition-corridor.sh \
  scripts/classify-phase-1-response-composition-state.sh \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh \
  scripts/checkpoint-evidence-composition-validation-reconciliation.sh

echo
echo "=== VERIFY STAGED DIFF ==="
git diff --cached --check
git status --short

git commit -m "Checkpoint Evidence Composition validation reconciliation"
git push

echo
echo "=== VERIFY CLEAN CHECKPOINT ==="
if [[ -n "$(git status --porcelain)" ]]; then
  echo "STOP: working tree is not clean after checkpoint."
  git status --short
  exit 2
fi

echo "WORKING_TREE_CLEAN"
echo "VALIDATION_RECONCILIATION_CHECKPOINT_CREATED"
echo "PHASE_2_START=BLOCKED"
echo "NEXT_ACTION=RERUN_PHASE_1_RESPONSE_COMPOSITION_RECLASSIFICATION"

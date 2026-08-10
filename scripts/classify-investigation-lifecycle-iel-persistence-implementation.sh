#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE IEL PERSISTENCE IMPLEMENTATION ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "STOP: working tree is not clean before classification."
  git status --short
  exit 2
fi

echo
echo "=== VERIFY REQUIRED IMPLEMENTATION CHECKPOINT ==="
if ! git merge-base --is-ancestor bfabff53 HEAD; then
  echo "STOP: repaired IEL persistence checkpoint bfabff53 is not an ancestor of HEAD."
  exit 2
fi

echo "REPAIRED_IEL_PERSISTENCE_CHECKPOINT_CONFIRMED"

echo
echo "=== VERIFY CLASSIFIED REPRESENTATION CONTRACT ==="
grep -n \
  -E 'IEL_REPRESENTATION=IEL_BOUNDED_LIFECYCLE_JSON|SCHEMA_EXTENSION=investigation_lifecycle_json_TEXT_NULL|HISTORICAL_ROWS=NULL_NO_BACKFILL' \
  scripts/classify-investigation-lifecycle-iel-representation.sh

echo
echo "=== VERIFY IEL PERSISTENCE SURFACE ==="
grep -n \
  -E 'investigation_lifecycle_json' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY MIGRATION LOCATION ==="
grep -n -A25 -B10 \
  'const lifecycleColumns' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY MIGRATION IS NOT INSIDE OPTIONAL TEXT ==="
optional_region="$(
  sed -n \
    '/function optionalText/,/export function createInterpretationEvidenceLedgerEntry/p' \
    db/matilda-interpretation-runtime.ts
)"

if printf '%s\n' "$optional_region" | grep -q 'lifecycleColumns'; then
  echo "STOP: lifecycle migration remains inside optionalText."
  exit 2
fi

echo "LIFECYCLE_MIGRATION_PLACEMENT_CONFIRMED"

echo
echo "=== VERIFY NO HISTORICAL LIFECYCLE BACKFILL ==="
if grep -nE \
  'investigation_lifecycle_json[[:space:]]*=' \
  db/matilda-interpretation-runtime.ts
then
  echo "STOP: lifecycle backfill assignment detected."
  exit 2
fi

echo "HISTORICAL_ROWS_NULL_NO_BACKFILL_CONFIRMED"

echo
echo "=== TARGETED PERSISTENCE CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== LINEAGE / CONTEXT REGRESSION ==="
npx tsx --test db/matilda-conversation-lineage.test.ts
npx tsx --test server/matilda-interpretation-lifecycle-provider.test.ts
npx tsx --test server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== CLASSIFICATION ==="
cat <<'FINDINGS'
Classification:

INVESTIGATION_LIFECYCLE_IEL_PERSISTENCE_IMPLEMENTED

Repository-supported determination:

1. Investigation Lifecycle has a bounded structured semantic response artifact.

2. The classified durable representation is:

   IEL_BOUNDED_LIFECYCLE_JSON

3. The Interpretation Evidence Ledger owns durable lifecycle persistence.

4. The IEL schema now carries the additive nullable column:

   investigation_lifecycle_json TEXT

5. Existing historical IEL rows remain NULL.

6. No lifecycle backfill is performed.

7. New IEL writes can persist nullable bounded Investigation Lifecycle JSON.

8. The migration is correctly owned by IEL table initialization.

9. The migration is not embedded in unrelated text-normalization logic.

10. Targeted persistence contract validation passes.

11. Existing conversation lineage behavior remains intact.

12. Existing lifecycle-provider behavior remains intact.

13. Existing Conversation Context Runtime behavior remains intact.

14. The bounded Investigation Lifecycle response contract remains intact.

15. The one-user-message -> one-workflow -> one-Ollama-invocation invariant remains intact.

16. Phase 1 Response Composition remains closed.

17. Workflow consumption of investigationLifecycle has not yet been added.

18. Therefore persistence capability is implemented, but end-to-end lifecycle
    continuity is not yet established.

19. Continuity validation remains deferred until the workflow consumption seam
    is reconciled and implemented.

20. The next unit must investigate the exact workflow consumption seam before
    any additional production implementation is authorized.

Do not change generation policy.

Do not add retries.

Do not add another model invocation.

Do not reopen Phase 1.

Do not reopen Adaptive Detail.

Do not reopen Evidence Composition.

Do not add lifecycle workflow consumption in this classification unit.

Do not add database backfill.

Preserve:

one user message
-> one workflow
-> one Ollama invocation.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_IEL_PERSISTENCE_IMPLEMENTED"
echo "PERSISTENCE_OWNER=IEL"
echo "IEL_REPRESENTATION=IEL_BOUNDED_LIFECYCLE_JSON"
echo "SCHEMA_EXTENSION=investigation_lifecycle_json_TEXT_NULL"
echo "HISTORICAL_ROWS=NULL_NO_BACKFILL"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_SEAM"

echo
echo "=== VERIFY PRODUCTION GENERATION / WORKFLOW UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production generation or workflow changed during persistence classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_GENERATION_AND_WORKFLOW_UNCHANGED"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^scripts/classify-investigation-lifecycle-iel-persistence-implementation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-investigation-lifecycle-iel-persistence-implementation.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle IEL persistence implementation"
git push

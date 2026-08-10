#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RECOVER INVESTIGATION LIFECYCLE PERSISTENCE CLASSIFICATION CHECKPOINT ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY KNOWN CHECKPOINTS ==="
git merge-base --is-ancestor bfabff53 HEAD || {
  echo "STOP: repaired IEL persistence checkpoint bfabff53 is not an ancestor of HEAD."
  exit 2
}

git merge-base --is-ancestor a3282df4 HEAD || {
  echo "STOP: reconciliation-script checkpoint a3282df4 is not an ancestor of HEAD."
  exit 2
}

echo "KNOWN_CHECKPOINTS_CONFIRMED"

echo
echo "=== VERIFY RECOVERY ARTIFACT EXISTS ==="
test -f scripts/classify-investigation-lifecycle-iel-persistence-implementation.sh || {
  echo "STOP: persistence classification artifact is missing."
  exit 2
}

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-iel-persistence-implementation\.sh$|^\?\? scripts/recover-investigation-lifecycle-persistence-classification-checkpoint\.sh$|^ M scripts/classify-investigation-lifecycle-iel-persistence-implementation\.sh$|^ M scripts/recover-investigation-lifecycle-persistence-classification-checkpoint\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_RECOVERY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY CLASSIFICATION CONTENT ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_IEL_PERSISTENCE_IMPLEMENTED|PERSISTENCE_OWNER=IEL|IEL_REPRESENTATION=IEL_BOUNDED_LIFECYCLE_JSON|SCHEMA_EXTENSION=investigation_lifecycle_json_TEXT_NULL|HISTORICAL_ROWS=NULL_NO_BACKFILL|NEXT_UNIT=RECONCILE_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_AFTER_IEL_PERSISTENCE' \
  scripts/classify-investigation-lifecycle-iel-persistence-implementation.sh

echo
echo "=== VERIFY PERSISTENCE IMPLEMENTATION REMAINS PRESENT ==="
grep -nE \
  'investigation_lifecycle_json|lifecycleColumns' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY MIGRATION PLACEMENT REMAINS REPAIRED ==="
optional_region="$(
  sed -n \
    '/function optionalText/,/export function createInterpretationEvidenceLedgerEntry/p' \
    db/matilda-interpretation-runtime.ts
)"

if printf '%s\n' "$optional_region" | grep -q 'lifecycleColumns'; then
  echo "STOP: lifecycle migration is inside optionalText."
  exit 2
fi

echo "LIFECYCLE_MIGRATION_PLACEMENT_CONFIRMED"

echo
echo "=== VERIFY NO HISTORICAL BACKFILL ==="
if grep -nE \
  'investigation_lifecycle_json[[:space:]]*=' \
  db/matilda-interpretation-runtime.ts
then
  echo "STOP: lifecycle backfill assignment detected."
  exit 2
fi

echo "HISTORICAL_ROWS_NULL_NO_BACKFILL_CONFIRMED"

echo
echo "=== TARGETED PERSISTENCE VALIDATION ==="
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
echo "=== VERIFY PRODUCTION GENERATION / WORKFLOW UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts
then
  echo "STOP: production runtime changed during recovery."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

cat <<'FINDINGS'

Recovery determination:

1. The repaired IEL persistence implementation remains established.

2. The persistence-classification artifact exists locally but was not
   checkpointed before the subsequent reconciliation wrapper was committed.

3. The reconciliation wrapper at a3282df4 did not execute its investigation
   because it correctly stopped on the unexpected untracked classification
   artifact.

4. No production workflow-consumption evidence was therefore collected by that
   stopped run.

5. No production runtime change resulted from that stopped reconciliation.

6. The missing persistence-classification checkpoint can be recovered without
   reverting the repository.

7. This recovery does not itself establish the workflow-to-IEL transport
   boundary.

8. After recovery, the next safe action is to rerun the workflow-consumption
   reconciliation from a clean tree so its repository evidence is actually
   collected.

9. Only after that successful reconciliation should the transport boundary be
   classified.

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_PERSISTENCE_CLASSIFICATION_RECOVERY_VALIDATED"
echo "RECONCILIATION_SCRIPT_CHECKPOINT=a3282df4"
echo "RECONCILIATION_EXECUTION=NOT_YET_ESTABLISHED"
echo "PRODUCTION_RUNTIME_UNCHANGED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=RERUN_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_RECONCILIATION"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "=== COMMIT RECOVERED CLASSIFICATION FIRST ==="
git add \
  scripts/classify-investigation-lifecycle-iel-persistence-implementation.sh

git diff --cached --check
git commit -m "Recover Investigation Lifecycle IEL persistence classification"
git push

echo
echo "=== VERIFY ONLY RECOVERY WRAPPER REMAINS ==="
remaining="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/recover-investigation-lifecycle-persistence-classification-checkpoint\.sh$|^ M scripts/recover-investigation-lifecycle-persistence-classification-checkpoint\.sh$' ||
  true
)"

if [[ -n "$remaining" ]]; then
  echo "STOP: unexpected changes remain after classification recovery:"
  printf '%s\n' "$remaining"
  exit 2
fi

echo "CLASSIFICATION_CHECKPOINT_RECOVERED"
echo "NEXT_ACTION=RERUN_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_RECONCILIATION"

git add \
  scripts/recover-investigation-lifecycle-persistence-classification-checkpoint.sh

git diff --cached --check
git commit -m "Document Investigation Lifecycle classification recovery"
git push

#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RERUN INVESTIGATION LIFECYCLE WORKFLOW CONSUMPTION RECONCILIATION ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLEAN BASELINE EXCEPT THIS SCRIPT ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/rerun-investigation-lifecycle-workflow-consumption-reconciliation\.sh$|^ M scripts/rerun-investigation-lifecycle-workflow-consumption-reconciliation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_RECONCILIATION_SCRIPT_ONLY"

echo
echo "=== VERIFY RECOVERY CHECKPOINT ==="
git merge-base --is-ancestor f98c00c1 HEAD || {
  echo "STOP: classification recovery checkpoint f98c00c1 is not an ancestor of HEAD."
  exit 2
}

echo "CLASSIFICATION_RECOVERY_CHECKPOINT_CONFIRMED"

echo
echo "=== VERIFY IEL PERSISTENCE CLASSIFICATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_IEL_PERSISTENCE_IMPLEMENTED|PERSISTENCE_OWNER=IEL|IEL_REPRESENTATION=IEL_BOUNDED_LIFECYCLE_JSON|SCHEMA_EXTENSION=investigation_lifecycle_json_TEXT_NULL|HISTORICAL_ROWS=NULL_NO_BACKFILL' \
  scripts/classify-investigation-lifecycle-iel-persistence-implementation.sh

echo
echo "=== OLLAMA RESULT / WORKFLOW CONSUMPTION SURFACE ==="
grep -n -A50 -B20 \
  -E 'ollamaChat\(|ollamaResult|durableInterpretation|investigationLifecycle' \
  server/matilda-chat-workflow.ts

echo
echo "=== IEL WRITE SURFACE ==="
grep -n -A70 -B25 \
  'createInterpretationEvidenceLedgerEntry' \
  server/matilda-chat-workflow.ts

echo
echo "=== IEL INPUT AND STORAGE REPRESENTATION ==="
grep -n -A45 -B15 \
  -E 'investigation_lifecycle_json|createInterpretationEvidenceLedgerEntry' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== MATILDA-AUTHORED LIFECYCLE TYPE ==="
grep -n -A45 -B15 \
  -E 'InvestigationLifecycle|investigationLifecycle' \
  scripts/utils/ollamaChat.ts |
head -n 320

echo
echo "=== CURRENT WORKFLOW LIFECYCLE REFERENCES ==="
workflow_lifecycle_refs="$(
  grep -nE \
    'investigationLifecycle|investigation_lifecycle_json' \
    server/matilda-chat-workflow.ts ||
  true
)"

if [[ -n "$workflow_lifecycle_refs" ]]; then
  printf '%s\n' "$workflow_lifecycle_refs"
  echo "STOP: workflow already contains Investigation Lifecycle consumption; baseline requires reclassification."
  exit 2
fi

echo "WORKFLOW_CONSUMPTION_ABSENT_CONFIRMED"

echo
echo "=== IEL WRITE REFERENCE COUNT ==="
iel_write_count="$(
  grep -c \
    'createInterpretationEvidenceLedgerEntry' \
    server/matilda-chat-workflow.ts ||
  true
)"

echo "IEL_WRITE_REFERENCE_COUNT=$iel_write_count"

if [[ "$iel_write_count" -lt 1 ]]; then
  echo "STOP: IEL workflow write seam could not be established."
  exit 2
fi

echo
echo "=== VERIFY EXISTING IEL REPRESENTATION BOUNDARY ==="
grep -n \
  'investigation_lifecycle_json?: string | null' \
  db/matilda-interpretation-runtime.ts

echo "IEL_STRING_PERSISTENCE_BOUNDARY_CONFIRMED"

echo
echo "=== SEARCH FOR EXISTING LIFECYCLE SERIALIZATION OWNERSHIP ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'JSON\.stringify\(.*investigationLifecycle|investigation_lifecycle_json.*JSON\.stringify|serialize.*InvestigationLifecycle' \
  server db scripts 2>/dev/null ||
true

echo
echo "=== RELEVANT WORKFLOW TEST SURFACE ==="
find server scripts db -type f \
  \( \
    -iname '*matilda*workflow*.test.ts' -o \
    -iname '*investigation*lifecycle*.test.ts' -o \
    -iname '*interpretation*ledger*.test.ts' \
  \) \
  -print 2>/dev/null |
sort

echo
echo "=== TARGETED PERSISTENCE VALIDATION ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-interpretation-runtime.ts
then
  echo "STOP: production runtime changed during reconciliation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts \
    db/matilda-interpretation-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

cat <<'FINDINGS'

Reconciliation determination:

INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_BOUNDARY_RECONCILED

Repository-supported state:

1. Matilda authors the bounded investigationLifecycle artifact inside the
   existing single structured semantic response.

2. The production workflow already owns consumption of that semantic result.

3. The Interpretation Evidence Ledger already owns durable lifecycle
   persistence.

4. The IEL storage representation is the established nullable field:

   investigation_lifecycle_json TEXT

5. The production workflow does not currently transport investigationLifecycle
   into the IEL write.

6. Therefore the missing current-turn capability is transport between two
   already-established ownership boundaries:

   Matilda-authored structured result
   ->
   production workflow
   ->
   IEL persistence

7. The workflow must not become Investigation Lifecycle interpretation
   authority.

8. It must not infer, repair, normalize, or independently determine lifecycle
   semantics.

9. Null lifecycle must remain valid for ordinary turns.

10. Existing historical rows remain NULL with no backfill.

11. Conversation-turn persistence does not require modification merely to
    persist the current-turn lifecycle artifact.

12. Living Draft behavior does not require modification for this transport.

13. Conversation Context Runtime does not require modification for this
    current-turn persistence unit.

14. Cross-turn continuity reconstruction remains a separate later capability.

15. Cross-turn lifecycle transition validation remains deferred.

16. No second model invocation is required.

17. Generation policy does not require modification.

18. Phase 1 Response Composition remains closed.

19. Before implementation, the repository must classify the exact
    representation boundary between the typed Matilda-authored artifact and the
    IEL's JSON persistence representation.

20. In particular, classification must determine whether serialization belongs
    at the workflow call site or inside the IEL persistence boundary.

21. That ownership decision must be made from repository evidence before
    production code is changed.

Smallest next unit:

CLASSIFY_INVESTIGATION_LIFECYCLE_WORKFLOW_TO_IEL_TRANSPORT_BOUNDARY

Do not implement workflow consumption in this unit.

Do not add continuity reconstruction.

Do not add transition validation.

Do not alter conversation-turn persistence.

Do not alter Living Draft behavior.

Do not alter Conversation Context Runtime.

Do not add another database field.

Do not backfill historical rows.

Do not change generation policy.

Do not add retries.

Do not add another model invocation.

Do not reopen Phase 1.

Preserve:

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

Preserve Matilda as Interpretation Authority.

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_RECONCILIATION_EXECUTED"
echo "WORKFLOW_CONSUMPTION=NOT_YET_IMPLEMENTED"
echo "IEL_PERSISTENCE_CAPABILITY=IMPLEMENTED"
echo "CONTINUITY_RECONSTRUCTION=DEFERRED"
echo "PRODUCTION_RUNTIME_UNCHANGED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_UNIT=CLASSIFY_INVESTIGATION_LIFECYCLE_WORKFLOW_TO_IEL_TRANSPORT_BOUNDARY"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/rerun-investigation-lifecycle-workflow-consumption-reconciliation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside reconciliation-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "RECONCILIATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add \
  scripts/rerun-investigation-lifecycle-workflow-consumption-reconciliation.sh

git diff --cached --check
git commit -m "Rerun Investigation Lifecycle workflow consumption reconciliation"
git push

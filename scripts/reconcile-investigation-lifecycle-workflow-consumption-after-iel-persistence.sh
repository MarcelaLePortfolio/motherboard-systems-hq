#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RECONCILE INVESTIGATION LIFECYCLE WORKFLOW CONSUMPTION AFTER IEL PERSISTENCE ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-investigation-lifecycle-workflow-consumption-after-iel-persistence\.sh$|^ M scripts/reconcile-investigation-lifecycle-workflow-consumption-after-iel-persistence\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_RECONCILIATION_SCRIPT_ONLY"

echo
echo "=== VERIFY IEL PERSISTENCE CLASSIFICATION ==="
test -f scripts/classify-investigation-lifecycle-iel-persistence-implementation.sh || {
  echo "STOP: IEL persistence classification artifact is missing."
  exit 2
}

grep -nE \
  'INVESTIGATION_LIFECYCLE_IEL_PERSISTENCE_IMPLEMENTED|NEXT_UNIT=RECONCILE_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_AFTER_IEL_PERSISTENCE' \
  scripts/classify-investigation-lifecycle-iel-persistence-implementation.sh

echo
echo "=== LOCATE OLLAMA RESULT CONSUMPTION ==="
grep -n -A35 -B15 \
  -E 'ollamaChat\(|ollamaResult|durableInterpretation|investigationLifecycle' \
  server/matilda-chat-workflow.ts

echo
echo "=== LOCATE IEL WRITE CALL ==="
grep -n -A45 -B20 \
  'createInterpretationEvidenceLedgerEntry' \
  server/matilda-chat-workflow.ts

echo
echo "=== LOCATE IEL INPUT CONTRACT ==="
grep -n -A35 -B15 \
  -E 'investigation_lifecycle_json|createInterpretationEvidenceLedgerEntry' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== LOCATE INVESTIGATION LIFECYCLE RESPONSE TYPE ==="
grep -n -A35 -B15 \
  -E 'MatildaInvestigationLifecycle|investigationLifecycle' \
  scripts/utils/ollamaChat.ts | head -n 260

echo
echo "=== LOCATE WORKFLOW TEST COVERAGE ==="
find server scripts -type f \
  \( -name '*matilda*workflow*.test.ts' -o \
     -name '*workflow*matilda*.test.ts' -o \
     -name '*investigation*lifecycle*.test.ts' \) \
  -print |
sort

echo
echo "=== VERIFY CURRENT WORKFLOW DOES NOT PERSIST LIFECYCLE ==="
if grep -q 'investigation_lifecycle_json' server/matilda-chat-workflow.ts; then
  echo "STOP: workflow already references investigation_lifecycle_json; repository state differs from classified baseline."
  exit 2
fi

echo "WORKFLOW_LIFECYCLE_PERSISTENCE_ABSENT_CONFIRMED"

echo
echo "=== VERIFY ONE IEL WRITE SEAM ==="
iel_write_count="$(
  grep -c 'createInterpretationEvidenceLedgerEntry' \
    server/matilda-chat-workflow.ts ||
  true
)"

echo "IEL_WRITE_REFERENCE_COUNT=$iel_write_count"

if [[ "$iel_write_count" -lt 1 ]]; then
  echo "STOP: no IEL write seam found."
  exit 2
fi

echo
echo "=== VERIFY PRODUCTION FILES UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts
then
  echo "STOP: production files changed during reconciliation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

cat <<'FINDINGS'

Reconciliation scope:

INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_AFTER_IEL_PERSISTENCE

Repository-supported state to classify from the evidence above:

1. Investigation Lifecycle semantic authorship already belongs to Matilda's
   bounded structured Ollama result.

2. Durable lifecycle persistence capability now belongs to the Interpretation
   Evidence Ledger.

3. Production workflow consumption must therefore be evaluated specifically at
   the existing boundary between the validated ollamaResult and the existing
   createInterpretationEvidenceLedgerEntry call.

4. No second semantic invocation is permitted.

5. The workflow must not reinterpret, infer, repair, or synthesize lifecycle
   semantics.

6. Null lifecycle must remain valid for ordinary turns.

7. Conversation-turn persistence must remain structurally independent from the
   lifecycle persistence addition.

8. Living Draft behavior must remain unchanged.

9. Conversation Context Runtime must remain unchanged unless repository evidence
   proves it is required merely to transport the current-turn artifact.

10. Cross-turn continuity reconstruction is a separate concern and remains
    deferred during this reconciliation.

11. The next classification must determine whether direct transport of the
    already-validated Matilda-authored artifact into the existing IEL write is
    sufficient, or whether the current IEL string input creates a representation
    boundary that requires a narrower persistence adapter.

12. No workflow implementation is authorized until that representation boundary
    is classified.

Do not implement workflow consumption in this unit.

Do not add lifecycle inference.

Do not add continuity reconstruction.

Do not add cross-turn transition validation.

Do not alter conversation-turn persistence.

Do not alter Living Draft behavior.

Do not alter Conversation Context Runtime.

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
echo "INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_RECONCILIATION_COMPLETE"
echo "IEL_PERSISTENCE_CAPABILITY=IMPLEMENTED"
echo "WORKFLOW_CONSUMPTION=NOT_YET_IMPLEMENTED"
echo "CONTINUITY_RECONSTRUCTION=DEFERRED"
echo "PRODUCTION_RUNTIME_UNCHANGED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_WORKFLOW_TO_IEL_TRANSPORT_BOUNDARY"

echo
echo "=== VERIFY RECONCILIATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-investigation-lifecycle-workflow-consumption-after-iel-persistence\.sh$' ||
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
  scripts/reconcile-investigation-lifecycle-workflow-consumption-after-iel-persistence.sh

git diff --cached --check
git commit -m "Reconcile Investigation Lifecycle workflow consumption"
git push

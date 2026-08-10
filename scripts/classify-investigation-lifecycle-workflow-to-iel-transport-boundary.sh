#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE WORKFLOW TO IEL TRANSPORT BOUNDARY ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY AUTHORIZED CLASSIFICATION SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-workflow-to-iel-transport-boundary\.sh$|^ M scripts/classify-investigation-lifecycle-workflow-to-iel-transport-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_CLASSIFICATION_SCRIPT_ONLY"

echo
echo "=== VERIFY RECONCILIATION CHECKPOINT ==="
git merge-base --is-ancestor 7da4eb24 HEAD || {
  echo "STOP: workflow-consumption reconciliation checkpoint 7da4eb24 is not an ancestor of HEAD."
  exit 2
}

echo "WORKFLOW_CONSUMPTION_RECONCILIATION_CHECKPOINT_CONFIRMED"

echo
echo "=== VERIFY RECONCILED STATE ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_BOUNDARY_RECONCILED|WORKFLOW_CONSUMPTION=NOT_YET_IMPLEMENTED|NEXT_UNIT=CLASSIFY_INVESTIGATION_LIFECYCLE_WORKFLOW_TO_IEL_TRANSPORT_BOUNDARY' \
  scripts/rerun-investigation-lifecycle-workflow-consumption-reconciliation.sh

echo
echo "=== VERIFY MATILDA-AUTHORED TYPED ARTIFACT ==="
grep -n -A25 -B10 \
  -E 'interface OllamaChatResult|MatildaInvestigationLifecycleArtifact|investigationLifecycle:' \
  scripts/utils/ollamaChat.ts |
head -n 220

echo
echo "=== VERIFY IEL CURRENT INPUT REPRESENTATION ==="
grep -n -A25 -B10 \
  'investigation_lifecycle_json?: string | null' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY IEL WRITE OWNS SQL REPRESENTATION ==="
grep -n -A40 -B15 \
  '@investigation_lifecycle_json' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== INSPECT EXISTING PERSISTENCE-BOUNDARY SERIALIZATION PATTERNS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'JSON\.stringify\(|_json\??:|_json:' \
  db server 2>/dev/null |
head -n 500 ||
true

echo
echo "=== INSPECT WORKFLOW SERIALIZATION RESPONSIBILITIES ==="
grep -n \
  'JSON.stringify' \
  server/matilda-chat-workflow.ts ||
true

echo
echo "=== INSPECT IEL INPUT OWNERSHIP PATTERN ==="
sed -n '1,340p' db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY CURRENT WORKFLOW STILL DOES NOT CONSUME LIFECYCLE ==="
if grep -qE \
  'investigationLifecycle|investigation_lifecycle_json' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: lifecycle workflow consumption already exists; classification baseline is stale."
  grep -nE \
    'investigationLifecycle|investigation_lifecycle_json' \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "WORKFLOW_CONSUMPTION_ABSENT_CONFIRMED"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-interpretation-runtime.ts
then
  echo "STOP: production runtime changed during transport-boundary classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts \
    db/matilda-interpretation-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

cat <<'FINDINGS'

Classification:

INVESTIGATION_LIFECYCLE_TRANSPORT_BOUNDARY=IEL_OWNS_PERSISTENCE_SERIALIZATION

Repository-supported determination:

1. Matilda owns Investigation Lifecycle semantic authorship.

2. The validated Ollama result exposes the semantic artifact as:

   MatildaInvestigationLifecycleArtifact | null

3. The production workflow owns orchestration and transport of Matilda-authored
   semantic results.

4. The Interpretation Evidence Ledger owns durable Investigation Lifecycle
   persistence.

5. The IEL database representation is:

   investigation_lifecycle_json TEXT NULL

6. The current IEL create input exposes that storage representation directly as:

   investigation_lifecycle_json?: string | null

7. That current input shape predates production workflow transport of the typed
   lifecycle artifact.

8. The workflow should not acquire ownership of the IEL's JSON storage
   representation merely because it transports the semantic artifact.

9. Workflow-side JSON serialization would couple orchestration code to the IEL's
   durable representation.

10. It would also create an unnecessary representation responsibility between
    Matilda semantic authorship and IEL persistence ownership.

11. The smallest ownership-preserving boundary is therefore:

    Matilda:
      authors MatildaInvestigationLifecycleArtifact | null

    Workflow:
      transports that artifact unchanged

    IEL:
      accepts the bounded semantic artifact and deterministically serializes it
      to investigation_lifecycle_json

12. IEL serialization is deterministic persistence transformation, not semantic
    interpretation.

13. Therefore IEL serialization does not violate Matilda's Interpretation
    Authority.

14. The IEL must not modify investigationIdentity.

15. The IEL must not modify governingQuestion.

16. The IEL must not modify lifecycleEvent.

17. The IEL must not modify lifecycleDetermination.

18. Non-null lifecycle serialization must preserve the exact validated semantic
    fields.

19. Null lifecycle must persist as SQL NULL.

20. No historical backfill is required.

21. No new database field is required.

22. Conversation-turn persistence remains unchanged.

23. Living Draft behavior remains unchanged.

24. Conversation Context Runtime remains unchanged for this current-turn
    transport unit.

25. Cross-turn continuity reconstruction remains deferred.

26. Cross-turn lifecycle transition validation remains deferred.

27. No generation-policy change is required.

28. No second Ollama invocation is required.

29. Phase 1 Response Composition remains closed.

30. The smallest implementation surface is now classifiable as:

    A. db/matilda-interpretation-runtime.ts
       - accept the bounded typed lifecycle artifact at the IEL API boundary;
       - deterministically serialize it for investigation_lifecycle_json;
       - preserve null as SQL NULL.

    B. server/matilda-chat-workflow.ts
       - pass ollamaResult.investigationLifecycle unchanged into the existing
         IEL write.

    C. narrow regression coverage
       - prove exact non-null transport;
       - prove null transport;
       - prove IEL-owned serialization;
       - prove one IEL write remains;
       - prove conversation-turn persistence remains unchanged;
       - prove one Ollama invocation remains.

Classification:

INVESTIGATION_LIFECYCLE_TYPED_IEL_ADAPTER_IMPLEMENTATION_READY

Implementation is not performed by this unit.

Smallest next unit:

IMPLEMENT_INVESTIGATION_LIFECYCLE_TYPED_IEL_ADAPTER_AND_WORKFLOW_TRANSPORT

Authorized future implementation surface must be limited to:

- db/matilda-interpretation-runtime.ts;
- server/matilda-chat-workflow.ts;
- narrowly required Investigation Lifecycle persistence/workflow tests;
- one implementation-unit script.

Do not add continuity reconstruction.

Do not add lifecycle retrieval.

Do not add cross-turn transition validation.

Do not alter conversation-turn persistence.

Do not alter Living Draft behavior.

Do not alter Conversation Context Runtime.

Do not change the database schema.

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
echo "INVESTIGATION_LIFECYCLE_TRANSPORT_BOUNDARY=IEL_OWNS_PERSISTENCE_SERIALIZATION"
echo "INVESTIGATION_LIFECYCLE_TYPED_IEL_ADAPTER_IMPLEMENTATION_READY"
echo "WORKFLOW_ROLE=DIRECT_TYPED_ARTIFACT_TRANSPORT"
echo "IEL_ROLE=DETERMINISTIC_PERSISTENCE_SERIALIZATION"
echo "NULL_LIFECYCLE=SQL_NULL"
echo "DATABASE_SCHEMA_CHANGE=NOT_REQUIRED"
echo "HISTORICAL_BACKFILL=NOT_REQUIRED"
echo "CONTINUITY_RECONSTRUCTION=DEFERRED"
echo "PRODUCTION_RUNTIME_UNCHANGED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=IMPLEMENT_INVESTIGATION_LIFECYCLE_TYPED_IEL_ADAPTER_AND_WORKFLOW_TRANSPORT"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-workflow-to-iel-transport-boundary\.sh$' ||
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

git add \
  scripts/classify-investigation-lifecycle-workflow-to-iel-transport-boundary.sh

git diff --cached --check
git commit -m "Classify Investigation Lifecycle workflow to IEL transport boundary"
git push

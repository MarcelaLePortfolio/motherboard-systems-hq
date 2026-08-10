#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE IEL REPRESENTATION ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-iel-representation\.sh$|^ M scripts/classify-investigation-lifecycle-iel-representation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_CLASSIFICATION_SCRIPT_ONLY"

echo
echo "=== VERIFY REPRESENTATION INVESTIGATION EXISTS ==="
test -f scripts/investigate-investigation-lifecycle-iel-representation.sh || {
  echo "STOP: IEL representation investigation artifact is missing."
  exit 2
}

grep -nE \
  'INVESTIGATION_LIFECYCLE_IEL_REPRESENTATION_EVIDENCE_COLLECTED|PERSISTENCE_OWNER=IEL|NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_IEL_REPRESENTATION' \
  scripts/investigate-investigation-lifecycle-iel-representation.sh

echo
echo "=== VERIFY PERSISTENCE OWNERSHIP ==="
test -f scripts/classify-investigation-lifecycle-persistence-ownership.sh || {
  echo "STOP: persistence-ownership classification artifact is missing."
  exit 2
}

grep -nE \
  'INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNER_IEL|IEL_REPRESENTATION_REQUIRES_SEPARATE_INVESTIGATION' \
  scripts/classify-investigation-lifecycle-persistence-ownership.sh

echo
echo "=== VERIFY BOUNDED RESPONSE ARTIFACT ==="
grep -n -A30 -B8 \
  -E 'MatildaInvestigationLifecycleArtifact|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination' \
  scripts/utils/ollamaChat.ts | head -n 300

echo
echo "=== VERIFY IEL SCHEMA / MIGRATION SURFACE ==="
grep -n -A45 -B15 \
  -E 'CREATE TABLE|PRAGMA table_info|ALTER TABLE' \
  db/matilda-interpretation-runtime.ts | head -n 500

echo
echo "=== VERIFY JSON PERSISTENCE PRECEDENT ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'JSON\.stringify|JSON\.parse|_json' \
  db server 2>/dev/null | head -n 500 || true

cat <<'FINDINGS'

Classification:

IEL_BOUNDED_LIFECYCLE_JSON

Repository-supported determination:

1. Investigation Lifecycle persistence ownership is the Interpretation Evidence
   Ledger.

2. The semantic-generation boundary already represents Investigation Lifecycle
   as one bounded nullable artifact.

3. That artifact contains exactly:

   investigationIdentity
   governingQuestion
   lifecycleEvent
   lifecycleDetermination

4. Those values form one semantic unit authored by Matilda.

5. Persistence should preserve that semantic unit atomically.

6. Four independently nullable IEL columns would permit partial lifecycle states
   that are invalid under the bounded response contract.

7. Avoiding those partial states would require additional cross-column
   invariants.

8. A single nullable bounded JSON representation preserves the artifact without
   introducing those invalid intermediate persistence states.

9. Repository persistence code already demonstrates TEXT-backed JSON
   serialization and parsing patterns.

10. The smallest supported additive IEL representation is therefore:

    investigation_lifecycle_json TEXT NULL

11. Historical IEL rows remain valid with:

    investigation_lifecycle_json = NULL

12. No historical lifecycle semantics may be invented or backfilled.

13. Ordinary non-investigation entries likewise represent lifecycle state as
    NULL.

14. A future write boundary may accept:

    investigationLifecycle:
      MatildaInvestigationLifecycleArtifact | null

15. The write mapping is:

    null
    -> SQL NULL

    validated artifact
    -> JSON.stringify(artifact)

16. A future read boundary must map:

    SQL NULL
    -> null

    non-null TEXT
    -> JSON.parse
    -> exact bounded lifecycle validation
    -> typed artifact

17. Malformed persisted JSON must fail closed.

18. Contract-invalid persisted lifecycle artifacts must fail closed.

19. Persistence must not repair or reinterpret semantic lifecycle facts.

20. investigationIdentity remains semantic identity.

21. It must not replace or derive from:

    entry_id
    project_id
    conversation_id
    interpretation lineage

22. lifecycleEvent remains distinct from supersession_status.

23. lifecycleDetermination remains distinct from unresolved_questions.

24. governingQuestion must not be reconstructed from durableInterpretation.

25. Multiple ordered IEL entries may carry the same investigationIdentity.

26. Those entries can later provide the durable event history required for
    Investigation Lifecycle continuity.

27. Continuity reconstruction remains deferred.

28. No dedicated Investigation Lifecycle table is currently justified.

29. No established repository requirement currently requires independently
    queryable lifecycle columns.

30. The bounded JSON representation therefore minimizes schema, migration,
    validation, compatibility, and rollback surface while preserving semantic
    fidelity.

Exact classification:

IEL_BOUNDED_LIFECYCLE_JSON

Proposed schema extension:

investigation_lifecycle_json TEXT NULL

Historical behavior:

NULL_NO_BACKFILL

Persistence owner:

IEL

Smallest future implementation surface:

- db/matilda-interpretation-runtime.ts
- narrow IEL Investigation Lifecycle persistence regression coverage
- minimum shared lifecycle type/validator extraction only if necessary to avoid
  divergent validation semantics

Required future validation:

- null lifecycle round-trip;
- exact non-null lifecycle round-trip;
- bounded lifecycleEvent preservation;
- advanced determination preservation;
- resolved determination preservation;
- malformed JSON rejection;
- contract-invalid artifact rejection;
- historical-row compatibility;
- existing IEL lineage preservation;
- project/conversation isolation preservation.

Not part of this classification:

- persistence implementation;
- workflow consumption;
- Conversation Context Runtime consumption;
- continuity reconstruction;
- transition validation across entries;
- conversation-turn persistence changes;
- lifecycle table creation;
- generation-policy changes.

Next unit:

IMPLEMENT_INVESTIGATION_LIFECYCLE_IEL_BOUNDED_JSON_PERSISTENCE

Do not implement in this unit.

Do not edit ollamaChat.ts.

Do not edit server/matilda-chat-workflow.ts.

Do not edit db/matilda-interpretation-runtime.ts.

Do not alter the database.

Do not add workflow consumption.

Do not add continuity validation.

Do not add retries.

Do not add another model invocation.

Do not change generation policy.

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
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION AND PERSISTENCE RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts
then
  echo "STOP: runtime or persistence changed during representation classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-conversation-context-runtime.ts \
    server/matilda-interpretation-lifecycle-provider.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts
  exit 2
fi

echo "PRODUCTION_AND_PERSISTENCE_RUNTIME_UNCHANGED"

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-iel-representation\.sh$' ||
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

echo
echo "INVESTIGATION_LIFECYCLE_IEL_REPRESENTATION_CLASSIFIED"
echo "IEL_REPRESENTATION=IEL_BOUNDED_LIFECYCLE_JSON"
echo "SCHEMA_EXTENSION=investigation_lifecycle_json_TEXT_NULL"
echo "HISTORICAL_ROWS=NULL_NO_BACKFILL"
echo "PERSISTENCE_OWNER=IEL"
echo "PERSISTENCE_NOT_ADDED"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=IMPLEMENT_INVESTIGATION_LIFECYCLE_IEL_BOUNDED_JSON_PERSISTENCE"

git add scripts/classify-investigation-lifecycle-iel-representation.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle IEL representation"
git push

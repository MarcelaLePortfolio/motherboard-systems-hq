#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE INVESTIGATION LIFECYCLE IEL REPRESENTATION ==="

REQUIRED_ANCESTOR="b866513c"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain persistence-ownership classification checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-investigation-lifecycle-iel-representation\.sh$|^ M scripts/investigate-investigation-lifecycle-iel-representation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_INVESTIGATION_SCRIPT_ONLY"

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY PERSISTENCE OWNERSHIP CLASSIFICATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_PERSISTENCE_OWNER_IEL|IEL_REPRESENTATION_REQUIRES_SEPARATE_INVESTIGATION|NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_IEL_REPRESENTATION' \
  scripts/classify-investigation-lifecycle-persistence-ownership.sh

echo
echo "=== IEL RUNTIME ==="
sed -n '1,460p' db/matilda-interpretation-runtime.ts

echo
echo "=== IEL SCHEMA / INITIALIZATION / MIGRATION SURFACE ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'CREATE TABLE|ALTER TABLE|PRAGMA table_info|interpretation_evidence|interpretation.*ledger|matilda_observation|minimum_sufficient_context|supporting_raw_evidence|unresolved_questions|lineage_references|supersession_status' \
  db server scripts 2>/dev/null | head -n 1200 || true

echo
echo "=== IEL CREATE CALLERS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'createInterpretationEvidenceLedgerEntry\(' \
  . 2>/dev/null | head -n 500 || true

echo
echo "=== IEL READ CALLERS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'listInterpretationEvidenceLedgerEntries\(' \
  . 2>/dev/null | head -n 500 || true

echo
echo "=== EXISTING JSON PERSISTENCE PATTERNS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'JSON\.stringify|JSON\.parse|_json|TEXT.*JSON|json_' \
  db server 2>/dev/null | head -n 900 || true

echo
echo "=== INVESTIGATION LIFECYCLE RESPONSE ARTIFACT ==="
grep -n -A50 -B15 \
  -E 'investigationLifecycle|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination' \
  scripts/utils/ollamaChat.ts | head -n 700

echo
echo "=== INTERPRETATION LIFECYCLE PROVIDER ==="
sed -n '1,340p' server/matilda-interpretation-lifecycle-provider.ts

echo
echo "=== CONTEXT / LIFECYCLE READ SURFACES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'MatildaInterpretationLifecycleEntry|interpretationLifecycleEntries|evaluatedInterpretations|supersession_status' \
  server db scripts 2>/dev/null | head -n 900 || true

cat <<'FINDINGS'

Investigation:

INVESTIGATION_LIFECYCLE_IEL_REPRESENTATION

Established facts:

1. Investigation Lifecycle persistence ownership is the Interpretation Evidence
   Ledger.

2. Investigation Lifecycle is one bounded Matilda-authored semantic artifact:

   investigationIdentity
   governingQuestion
   lifecycleEvent
   lifecycleDetermination

3. investigationIdentity is semantic identity, not storage identity.

4. One investigation may span multiple ordered IEL entries.

5. Historical IEL entries contain no explicit Investigation Lifecycle artifact.

6. Historical entries must remain valid without invented backfill semantics.

7. Existing generic IEL fields must not be repurposed.

Candidate A:

IEL_EXPLICIT_STRUCTURED_LIFECYCLE_FIELDS

Potential schema:

investigation_identity TEXT NULL
governing_question TEXT NULL
lifecycle_event TEXT NULL
lifecycle_determination TEXT NULL

Required evaluation:

- schema migration surface;
- partial-null-state risk;
- atomic artifact validation;
- typed write behavior;
- typed read behavior;
- historical-row compatibility;
- ordered reconstruction;
- queryability;
- rollback complexity;
- number of runtime mappings changed.

Candidate B:

IEL_BOUNDED_LIFECYCLE_JSON

Potential schema:

investigation_lifecycle_json TEXT NULL

containing exactly:

{
  investigationIdentity,
  governingQuestion,
  lifecycleEvent,
  lifecycleDetermination
}

Required evaluation:

- schema migration surface;
- atomic preservation of the semantic artifact;
- exact mapping from the existing response contract;
- typed serialization;
- typed fail-closed parsing;
- historical-row compatibility through NULL;
- ordered reconstruction;
- queryability required by known runtime behavior;
- rollback complexity;
- number of runtime mappings changed.

Classification criteria:

Prefer the smallest representation only if repository evidence shows that it:

1. preserves all four Matilda-authored facts without semantic transformation;

2. preserves their atomic relationship;

3. safely represents ordinary non-investigation turns;

4. safely represents historical IEL rows without semantic backfill;

5. supports deterministic typed write and read boundaries;

6. supports future continuity reconstruction across ordered IEL entries;

7. preserves project/conversation isolation through the owning IEL entry;

8. preserves existing interpretation-entry lineage;

9. does not create a second persistence owner;

10. does not require parsing lifecycle semantics from prose;

11. does not require deterministic generation of semantic lifecycle facts;

12. minimizes schema, migration, rollback, and compatibility surface without
    weakening validation.

Required classification:

Exactly one of:

IEL_EXPLICIT_STRUCTURED_LIFECYCLE_FIELDS
IEL_BOUNDED_LIFECYCLE_JSON
IEL_REPRESENTATION_REQUIRES_MORE_EVIDENCE

If one representation is supported, identify:

- exact proposed schema extension;
- historical-row behavior;
- write boundary;
- read boundary;
- validation boundary;
- future continuity reconstruction seam;
- smallest implementation surface;
- smallest regression-test surface;
- rollback path.

Do not implement.

Do not edit ollamaChat.ts.

Do not edit server/matilda-chat-workflow.ts.

Do not edit Conversation Context Runtime.

Do not edit the interpretation lifecycle provider.

Do not edit db/matilda-interpretation-runtime.ts.

Do not alter the database.

Do not add columns.

Do not add JSON persistence.

Do not create a lifecycle table.

Do not change conversation-turn persistence.

Do not add workflow consumption.

Do not add continuity validation.

Do not generate investigationIdentity.

Do not infer lifecycleEvent.

Do not infer lifecycleDetermination.

Do not parse lifecycle semantics from durableInterpretation.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

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
  echo "STOP: production runtime or persistence changed during IEL representation investigation."
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
  grep -vE '^scripts/investigate-investigation-lifecycle-iel-representation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside investigation-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_IEL_REPRESENTATION_EVIDENCE_COLLECTED"
echo "PERSISTENCE_OWNER=IEL"
echo "IEL_REPRESENTATION=UNCLASSIFIED_PENDING_EVIDENCE_REVIEW"
echo "PERSISTENCE_NOT_ADDED"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_IEL_REPRESENTATION"

git add scripts/investigate-investigation-lifecycle-iel-representation.sh
git diff --cached --check
git commit -m "Investigate Investigation Lifecycle IEL representation"
git push

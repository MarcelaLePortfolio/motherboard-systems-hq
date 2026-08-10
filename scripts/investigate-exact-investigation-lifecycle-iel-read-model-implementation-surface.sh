#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE EXACT INVESTIGATION LIFECYCLE IEL READ MODEL IMPLEMENTATION SURFACE ==="

REQUIRED_ANCESTOR="d229b9cf"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: IEL reconstruction investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY EXPECTED CLASSIFICATION CHECKPOINT IF PRESENT ==="
if git log --format='%H %s' -20 | grep -q 'Classify Investigation Lifecycle IEL reconstruction read seam'; then
  git log --oneline -5
  echo "READ_SEAM_CLASSIFICATION_CHECKPOINT_PRESENT"
else
  echo "NOTICE: classification commit not found in recent history; continuing from verified investigation ancestor only."
fi

echo
echo "=== VERIFY INVESTIGATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-exact-investigation-lifecycle-iel-read-model-implementation-surface\.sh$|^ M scripts/investigate-exact-investigation-lifecycle-iel-read-model-implementation-surface\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== IEL RUNTIME COMPLETE EXPORTED API ==="
grep -nE \
  '^export (interface|type|function|async function|const|class) ' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== IEL RUNTIME TOP-LEVEL TYPES ==="
sed -n '1,140p' db/matilda-interpretation-runtime.ts

echo
echo "=== IEL TABLE SCHEMA ==="
grep -n -A70 -B10 \
  'CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== IEL INSERT PATH ==="
grep -n -A130 -B30 \
  'INSERT INTO matilda_interpretation_evidence_ledger' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== IEL SELECT STATEMENTS IN OWNER RUNTIME ==="
grep -n -A100 -B35 \
  -E 'SELECT|FROM matilda_interpretation_evidence_ledger' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== ALL PRODUCTION IEL TABLE READERS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.test.ts' \
  --exclude='*.sh' \
  'FROM matilda_interpretation_evidence_ledger' \
  db server scripts 2>/dev/null ||
true

echo
echo "=== ALL PRODUCTION IMPORTS FROM IEL RUNTIME ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.test.ts' \
  --exclude='*.sh' \
  -E \
  'from ["'\''].*matilda-interpretation-runtime|require\(.*matilda-interpretation-runtime' \
  server db scripts 2>/dev/null ||
true

echo
echo "=== ALL IEL EXPORTED FUNCTION CALLERS ==="
exports="$(
  grep -E '^export (async )?function [A-Za-z0-9_]+' \
    db/matilda-interpretation-runtime.ts |
  sed -E 's/^export (async )?function ([A-Za-z0-9_]+).*/\2/' ||
  true
)"

for fn in $exports; do
  echo
  echo "--- CALLERS: $fn ---"
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.test.ts' \
    --exclude='*.sh' \
    "$fn" \
    server db scripts 2>/dev/null ||
  true
done

echo
echo "=== INTERPRETATION CONTEXT RUNTIME ==="
if [[ -f server/matilda-interpretation-context-runtime.ts ]]; then
  cat server/matilda-interpretation-context-runtime.ts
else
  echo "NO server/matilda-interpretation-context-runtime.ts"
fi

echo
echo "=== INTERPRETATION CONTEXT RUNTIME TEST ==="
if [[ -f server/matilda-interpretation-context-runtime.test.ts ]]; then
  cat server/matilda-interpretation-context-runtime.test.ts
else
  echo "NO server/matilda-interpretation-context-runtime.test.ts"
fi

echo
echo "=== LIFECYCLE PROVIDER ==="
cat server/matilda-interpretation-lifecycle-provider.ts

echo
echo "=== LIFECYCLE PROVIDER TEST ==="
cat server/matilda-interpretation-lifecycle-provider.test.ts

echo
echo "=== WORKFLOW INTERPRETATION READ COMPOSITION ==="
grep -n -A300 -B120 \
  -E \
  'listMatildaInterpretation|readMatildaInterpretation|getMatildaInterpretation|interpretationEntries|interpretations|evaluatedInterpretations|lifecycleEntries|conversationContext' \
  server/matilda-chat-workflow.ts |
head -n 2200

echo
echo "=== CONVERSATION CONTEXT INTERPRETATION INPUT TYPES ==="
grep -n -A220 -B60 \
  -E \
  'interpretations|evaluatedInterpretations|contaminationEvaluations|selectedHistory|MatildaConversationContext' \
  server/matilda-conversation-context-runtime.ts

echo
echo "=== EXISTING READ MODEL FIELD SHAPES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E \
  'entry_id|conversation_id|turn_id|durable_interpretation|supersession_status|authority_status' \
  db/matilda-interpretation-runtime.ts \
  server/matilda-interpretation-context-runtime.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-chat-workflow.ts 2>/dev/null |
head -n 2200 ||
true

echo
echo "=== DOES EXISTING IEL SELECT PROJECT LIFECYCLE JSON? ==="
select_lifecycle="$(
  grep -n -B30 -A80 \
    'FROM matilda_interpretation_evidence_ledger' \
    db/matilda-interpretation-runtime.ts |
  grep 'investigation_lifecycle_json' ||
  true
)"

if [[ -n "$select_lifecycle" ]]; then
  printf '%s\n' "$select_lifecycle"
  echo "IEL_SELECT_LIFECYCLE_JSON=YES"
else
  echo "IEL_SELECT_LIFECYCLE_JSON=NO"
fi

echo
echo "=== DOES EXISTING IEL RETURN TYPE CARRY LIFECYCLE? ==="
returned_lifecycle="$(
  sed -n '1,140p' db/matilda-interpretation-runtime.ts |
  grep -E 'investigationLifecycle|investigation_lifecycle_json' ||
  true
)"

if [[ -n "$returned_lifecycle" ]]; then
  printf '%s\n' "$returned_lifecycle"
  echo "IEL_RETURN_TYPE_LIFECYCLE_FIELD=YES_OR_INPUT_ONLY_REQUIRES_CLASSIFICATION"
else
  echo "IEL_RETURN_TYPE_LIFECYCLE_FIELD=NO"
fi

echo
echo "=== CURRENT LIFECYCLE TYPE DEFINITION ==="
grep -n -A20 -B5 \
  'export interface MatildaInvestigationLifecycleArtifact' \
  scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT LIFECYCLE VALIDATION BODY ==="
sed -n '523,630p' scripts/utils/ollamaChat.ts

echo
echo "=== SEARCH FOR REUSABLE VALIDATION MODULES / PATTERNS ==="
find scripts server db -type f \
  \( \
    -iname '*validator*.ts' -o \
    -iname '*validation*.ts' -o \
    -iname '*schema*.ts' -o \
    -iname '*contract*.ts' \
  \) \
  -print 2>/dev/null |
sort |
head -n 500

echo
echo "=== JSON DESERIALIZATION PATTERNS IN DB READ BOUNDARIES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.test.ts' \
  --exclude='*.sh' \
  -E 'JSON\.parse' \
  db 2>/dev/null |
head -n 1000 ||
true

echo
echo "=== FAIL-CLOSED DB READ PATTERNS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.test.ts' \
  --exclude='*.sh' \
  -E \
  'throw new Error|JSON\.parse|malformed|invalid .*json|invalid .*JSON' \
  db 2>/dev/null |
head -n 1200 ||
true

echo
echo "=== PROJECT / CONVERSATION SCOPING AT IEL READ BOUNDARY ==="
grep -n -A120 -B40 \
  -E \
  'project_id|conversation_id|ORDER BY|LIMIT' \
  db/matilda-interpretation-runtime.ts |
head -n 1800

echo
echo "=== IEL / LINEAGE REGRESSION TESTS ==="
find db server scripts -type f \
  \( \
    -iname '*interpretation*.test.ts' -o \
    -iname '*lineage*.test.ts' -o \
    -iname '*lifecycle*.test.ts' \
  \) \
  -print 2>/dev/null |
sort

echo
echo "=== VERIFY CURRENT COMPLETED CONTRACTS ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

npx tsx --test \
  server/matilda-interpretation-lifecycle-provider.test.ts

npx tsx --test \
  server/matilda-interpretation-context-runtime.test.ts

npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

cat <<'FINDINGS'

Exact IEL reconstruction implementation-surface investigation:

The previous evidence established:

- one existing MatildaInvestigationLifecycleArtifact semantic contract,
- IEL ownership of nullable investigation_lifecycle_json persistence,
- no production persisted-lifecycle reconstruction,
- no dedicated prior-lifecycle semantic context,
- lifecycle validation currently embedded in Ollama structured-response parsing.

This investigation must now establish the exact production implementation
surface rather than assume one.

Required determinations:

1. Identify the exact existing production function that reads IEL entries used
   by Matilda's workflow/context composition.

2. Identify its exact returned TypeScript type.

3. Determine whether investigation_lifecycle_json is:
   - absent from the SELECT projection,
   - selected but discarded,
   - present in a raw row type,
   - or already exposed somewhere not previously recognized.

4. Determine whether extending that existing read path is sufficient or whether
   a deterministic adapter immediately above it is structurally cleaner.

5. Do not create a parallel IEL query merely to retrieve lifecycle state if the
   existing workflow already consumes an IEL read model that can safely carry
   it.

6. Determine the narrowest location for a reusable bounded lifecycle artifact
   parser/validator.

7. The parser/validator must reuse the existing
   MatildaInvestigationLifecycleArtifact contract and bounded event vocabulary.

8. It must support two distinct callers without semantic drift:
   - Ollama structured-response validation,
   - persisted IEL lifecycle reconstruction.

9. It must preserve current fail-closed response behavior.

10. Persisted SQL NULL must remain semantic null.

11. Persisted malformed non-null JSON must fail closed.

12. Valid persisted JSON must reconstruct the exact authored semantic fields
    without normalization beyond the already-established bounded contract.

13. Reconstruction must not derive missing semantic fields from:
    durableInterpretation,
    reply,
    chronology,
    supersession_status,
    authority evaluation,
    contamination evaluation,
    conversation turns,
    or Living Draft state.

14. Existing project/conversation scoping and chronology should be reused if
    already owned by the production IEL reader.

15. Conversation-turn persistence remains outside this implementation surface.

16. Conversation Context Runtime remains outside the reconstruction unit unless
    repository evidence proves the IEL reader is inseparable from that runtime.

17. selectedHistory remains outside the reconstruction unit.

18. Prior-lifecycle Ollama context remains outside the reconstruction unit.

19. Cross-turn transition validation remains downstream.

20. No second model invocation is permitted or required.

Implementation authorization remains withheld until this evidence is
classified.

Preserve:

Matilda
= Interpretation Authority and lifecycle semantic author

Workflow
= current-turn typed transport

IEL
= persistence owner

Reconstruction
= deterministic recovery of already-authored semantic state

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "EXACT_INVESTIGATION_LIFECYCLE_IEL_READ_MODEL_IMPLEMENTATION_SURFACE_EVIDENCE_COLLECTED"
echo "RECONSTRUCTION_IMPLEMENTATION_NOT_STARTED"
echo "PARALLEL_IEL_READ_PATH_NOT_ADDED"
echo "PRIOR_LIFECYCLE_CONTEXT_NOT_ADDED"
echo "CROSS_TURN_CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_EXACT_INVESTIGATION_LIFECYCLE_IEL_READ_MODEL_IMPLEMENTATION_SURFACE"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-interpretation-context-runtime.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during exact read-model investigation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-interpretation-lifecycle-provider.ts \
    server/matilda-interpretation-context-runtime.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-exact-investigation-lifecycle-iel-read-model-implementation-surface\.sh$' ||
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

git add scripts/investigate-exact-investigation-lifecycle-iel-read-model-implementation-surface.sh
git diff --cached --check
git commit -m "Investigate Investigation Lifecycle IEL read model surface"
git push

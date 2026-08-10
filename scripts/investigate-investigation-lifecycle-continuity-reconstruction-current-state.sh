#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE INVESTIGATION LIFECYCLE CONTINUITY RECONSTRUCTION CURRENT STATE ==="

REQUIRED_ANCESTOR="2f923cf7"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: current-turn lifecycle completion checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY INVESTIGATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-investigation-lifecycle-continuity-reconstruction-current-state\.sh$|^ M scripts/investigate-investigation-lifecycle-continuity-reconstruction-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY CURRENT-TURN PATH CLOSURE ==="
grep -nE \
  'CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH_COMPLETE|CONTINUITY_RECONSTRUCTION=DEFERRED|NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_CONTINUITY_RECONSTRUCTION_CURRENT_STATE' \
  scripts/classify-investigation-lifecycle-workflow-transport-implementation.sh

echo
echo "=== PERSISTED LIFECYCLE JSON REFERENCES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  'investigation_lifecycle_json' \
  db server scripts 2>/dev/null ||
true

echo
echo "=== SEMANTIC INVESTIGATION LIFECYCLE REFERENCES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E 'investigationLifecycle|investigation_lifecycle|MatildaInvestigationLifecycleArtifact' \
  db server scripts 2>/dev/null |
head -n 1000 ||
true

echo
echo "=== IEL READ PATHS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'FROM matilda_interpretation_evidence_ledger|SELECT .*matilda_interpretation_evidence_ledger|list.*Interpretation|read.*Interpretation|get.*Interpretation' \
  db server 2>/dev/null |
head -n 800 ||
true

echo
echo "=== IEL RUNTIME READ SURFACE ==="
grep -n -A220 -B40 \
  -E 'SELECT|listMatilda|InterpretationEvidenceLedger|investigation_lifecycle_json' \
  db/matilda-interpretation-runtime.ts |
head -n 1200

echo
echo "=== LIFECYCLE PROVIDER ==="
test -f server/matilda-interpretation-lifecycle-provider.ts || {
  echo "STOP: lifecycle provider is missing."
  exit 2
}

cat server/matilda-interpretation-lifecycle-provider.ts

echo
echo "=== LIFECYCLE PROVIDER TEST ==="
test -f server/matilda-interpretation-lifecycle-provider.test.ts && \
  cat server/matilda-interpretation-lifecycle-provider.test.ts

echo
echo "=== CONVERSATION CONTEXT RUNTIME ==="
cat server/matilda-conversation-context-runtime.ts

echo
echo "=== WORKFLOW CONTEXT COMPOSITION ==="
grep -n -A160 -B60 \
  -E 'conversationContext|selectedHistory|evaluatedInterpretations|contaminationEvaluations|ollamaChat\(' \
  server/matilda-chat-workflow.ts |
head -n 1400

echo
echo "=== SELECTED HISTORY TYPES AND CONSTRUCTION ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'selectedHistory|SelectedHistory|select.*History|historySelection' \
  server db scripts 2>/dev/null |
head -n 1200 ||
true

echo
echo "=== AUTHORITY / SUPERSESSION LIFECYCLE REFERENCES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'supersession_status|eligible_superseded|authorityStatus|authority|lifecycleEntries' \
  server db scripts 2>/dev/null |
head -n 1200 ||
true

echo
echo "=== OLLAMA CONTEXT INPUT ==="
grep -n -A220 -B60 \
  -E 'export async function ollamaChat|selectedHistory|conversationHistory|projectContext|investigationLifecycle' \
  scripts/utils/ollamaChat.ts |
head -n 1600

echo
echo "=== EXISTING LIFECYCLE JSON RECONSTRUCTION ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E 'JSON\.parse\(.*investigation|investigation_lifecycle_json.*JSON\.parse|parse.*Investigation.*Lifecycle' \
  db server scripts 2>/dev/null ||
true

echo
echo "=== CONTINUITY / RECONSTRUCTION REFERENCES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'continuity|reconstruct|reconstruction|governingQuestion|lifecycleDetermination|lifecycleEvent' \
  server db scripts docs 2>/dev/null |
head -n 1600 ||
true

echo
echo "=== RELEVANT TEST SURFACE ==="
find db server scripts -type f \
  \( \
    -iname '*lifecycle*.test.ts' -o \
    -iname '*conversation*context*.test.ts' -o \
    -iname '*history*.test.ts' -o \
    -iname '*interpretation*.test.ts' \
  \) \
  -print 2>/dev/null |
sort

echo
echo "=== CURRENT CONTRACT REGRESSION ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

npx tsx --test \
  server/matilda-interpretation-lifecycle-provider.test.ts

npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during continuity investigation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-interpretation-lifecycle-provider.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

cat <<'FINDINGS'

Investigation questions:

1. Is investigation_lifecycle_json selected by any production read path?

2. Is persisted lifecycle JSON exposed by an existing IEL read model?

3. Is persisted lifecycle JSON parsed into the bounded
   MatildaInvestigationLifecycleArtifact representation?

4. Does matilda-interpretation-lifecycle-provider represent semantic
   Investigation Lifecycle continuity, or only authority / supersession state?

5. Does Conversation Context Runtime carry reconstructed Investigation
   Lifecycle state?

6. Does selectedHistory carry investigationIdentity, governingQuestion,
   lifecycleEvent, or lifecycleDetermination?

7. Does semantic generation receive prior Investigation Lifecycle state?

8. If reconstruction is absent, which existing architectural layer is the
   narrowest correct owner?

9. Can reconstruction use the existing workflow and Ollama invocation without
   introducing another model call?

10. What exact runtime files would comprise the smallest safe implementation
    surface?

11. Which existing tests can prove isolation, immutability, chronology,
    authority filtering, and semantic-generation transport remain intact?

12. What rollback surface would remove continuity reconstruction without
    reopening completed current-turn transport and persistence?

Classification discipline:

Do not infer semantic continuity from the phrase "lifecycle provider."

Do not infer reconstruction merely because investigation_lifecycle_json is
persisted.

Do not infer semantic-generation availability merely because selectedHistory
exists.

Do not infer context ownership merely because Conversation Context Runtime
exists.

Require explicit repository evidence.

Protected determination:

CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH_COMPLETE

Deferred:

INVESTIGATION_LIFECYCLE_CONTINUITY_RECONSTRUCTION

INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION

This unit is investigation only.

Do not implement continuity reconstruction.

Do not implement transition validation.

Do not modify lifecycle persistence.

Do not modify conversation-turn persistence.

Do not modify Living Draft behavior.

Do not modify Response Composition.

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
echo "INVESTIGATION_LIFECYCLE_CONTINUITY_RECONSTRUCTION_EVIDENCE_COLLECTED"
echo "CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH_REMAINS_COMPLETE"
echo "CONTINUITY_IMPLEMENTATION_NOT_STARTED"
echo "CROSS_TURN_TRANSITION_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_CONTINUITY_RECONSTRUCTION_CURRENT_STATE"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-investigation-lifecycle-continuity-reconstruction-current-state\.sh$' ||
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

git add \
  scripts/investigate-investigation-lifecycle-continuity-reconstruction-current-state.sh

git diff --cached --check
git commit -m "Investigate Investigation Lifecycle continuity reconstruction"
git push

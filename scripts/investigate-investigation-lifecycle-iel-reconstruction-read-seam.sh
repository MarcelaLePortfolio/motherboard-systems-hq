#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE INVESTIGATION LIFECYCLE IEL RECONSTRUCTION READ SEAM ==="

REQUIRED_ANCESTOR="39e3346a"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: continuity classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/investigate-investigation-lifecycle-iel-reconstruction-read-seam\.sh$|^ M scripts/investigate-investigation-lifecycle-iel-reconstruction-read-seam\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING CLASSIFICATION ==="
grep -nE \
  'IEL_LIFECYCLE_RECONSTRUCTION=ABSENT|DEDICATED_PRIOR_LIFECYCLE_CONTEXT=ABSENT|SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=ABSENT|NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION_READ_SEAM' \
  scripts/classify-investigation-lifecycle-continuity-reconstruction-current-state.sh

echo
echo "=== IEL TYPE / STORAGE CONTRACT ==="
grep -n -A40 -B20 \
  -E 'MatildaInvestigationLifecycleArtifact|investigation_lifecycle_json' \
  db/matilda-interpretation-runtime.ts |
head -n 500

echo
echo "=== IEL PRODUCTION READ FUNCTIONS ==="
grep -n -A120 -B30 \
  -E '^export (async )?function .*Interpretation|^export const .*Interpretation|SELECT|FROM matilda_interpretation_evidence_ledger' \
  db/matilda-interpretation-runtime.ts |
head -n 1600

echo
echo "=== ALL IEL TABLE READERS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  'FROM matilda_interpretation_evidence_ledger' \
  db server scripts 2>/dev/null ||
true

echo
echo "=== ALL LIFECYCLE JSON PRODUCTION REFERENCES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  'investigation_lifecycle_json' \
  db server scripts 2>/dev/null ||
true

echo
echo "=== IEL ROW / ENTRY TYPES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E \
  'InterpretationEvidenceLedger|InterpretationEvidence|MatildaInterpretation|InterpretationEntry' \
  db server scripts 2>/dev/null |
head -n 1400 ||
true

echo
echo "=== IEL READ CALLERS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E \
  'listMatildaInterpretation|readMatildaInterpretation|getMatildaInterpretation|listInterpretation|readInterpretation|getInterpretation' \
  db server scripts 2>/dev/null |
head -n 1400 ||
true

echo
echo "=== INTERPRETATION LIFECYCLE PROVIDER ==="
cat server/matilda-interpretation-lifecycle-provider.ts

echo
echo "=== INTERPRETATION LIFECYCLE PROVIDER CALLERS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E \
  'matilda-interpretation-lifecycle-provider|select.*Lifecycle|resolve.*Lifecycle|lifecycleEntries' \
  server db scripts 2>/dev/null |
head -n 1200 ||
true

echo
echo "=== AUTHORITY EVALUATION INPUT / OUTPUT ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E \
  'evaluate.*Authority|authorityStatus|eligible_superseded|ineligible_superseded|unresolved' \
  server db scripts 2>/dev/null |
head -n 1400 ||
true

echo
echo "=== CONVERSATION CONTEXT ASSEMBLY ==="
grep -n -A260 -B80 \
  -E \
  'export.*ConversationContext|compose.*ConversationContext|evaluatedInterpretations|selectedHistory|interpretations' \
  server/matilda-conversation-context-runtime.ts

echo
echo "=== WORKFLOW READ / CONTEXT SEQUENCE ==="
grep -n -A260 -B100 \
  -E \
  'listMatilda|interpretation|lifecycle|conversationContext|selectedHistory|ollamaChat\(' \
  server/matilda-chat-workflow.ts |
head -n 2000

echo
echo "=== EXISTING JSON PARSING PATTERNS IN IEL / DB RUNTIMES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.test.ts' \
  --exclude='*.sh' \
  -E \
  'JSON\.parse|safe.*parse|parse.*JSON' \
  db server 2>/dev/null |
head -n 1200 ||
true

echo
echo "=== EXISTING FAIL-CLOSED PARSING / VALIDATION PATTERNS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.test.ts' \
  --exclude='*.sh' \
  -E \
  'throw new Error|invalid.*JSON|malformed|fail.closed|parseStructured|validate.*Artifact' \
  db server scripts/utils 2>/dev/null |
head -n 1400 ||
true

echo
echo "=== INVESTIGATION LIFECYCLE TYPE OWNER ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E \
  'export (type|interface).*MatildaInvestigationLifecycleArtifact|type MatildaInvestigationLifecycleArtifact|interface MatildaInvestigationLifecycleArtifact' \
  scripts server db 2>/dev/null ||
true

echo
echo "=== CURRENT LIFECYCLE VALIDATOR ==="
grep -n -A180 -B40 \
  -E \
  'MatildaInvestigationLifecycleArtifact|validate.*Investigation|investigationLifecycle' \
  scripts/utils/ollamaChat.ts |
head -n 1400

echo
echo "=== TESTS AROUND IEL READ / LINEAGE / CONTEXT ==="
find db server scripts -type f \
  \( \
    -iname '*interpretation*.test.ts' -o \
    -iname '*lifecycle*.test.ts' -o \
    -iname '*lineage*.test.ts' -o \
    -iname '*conversation*context*.test.ts' \
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
  echo "STOP: production runtime changed during reconstruction read-seam investigation."
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

Investigation objective:

Identify the narrowest repository-supported read/reconstruction seam for the
already-persisted Matilda-authored Investigation Lifecycle artifact.

Questions requiring repository evidence:

1. Which production function currently owns reads from
   matilda_interpretation_evidence_ledger?

2. Does that read model currently omit investigation_lifecycle_json from its
   SELECT projection, returned type, or both?

3. Is there an existing IEL entry/read-model type that can safely gain a
   nullable typed Investigation Lifecycle field without changing persistence
   ownership?

4. Should reconstruction occur:
   - inside the IEL repository read boundary,
   - in a dedicated deterministic adapter immediately above IEL,
   - or elsewhere?

5. Which option best preserves the existing ownership rule that IEL owns
   persistence representation while semantic consumers receive typed state?

6. Can the existing bounded MatildaInvestigationLifecycleArtifact type be
   reused without creating a second lifecycle representation?

7. Can the existing lifecycle validator be safely shared for persisted data,
   or is it coupled to Ollama response parsing?

8. What should happen if persisted lifecycle JSON is malformed?

9. Can malformed persisted lifecycle state fail closed without invalidating
   historical rows whose lifecycle value is SQL NULL?

10. Does reconstruction need project and conversation scoping already supplied
    by the existing IEL read path?

11. Does chronology already exist at the relevant read seam?

12. Can reconstruction be implemented without altering conversation-turn
    persistence?

13. Can reconstruction be implemented without modifying Conversation Context
    Runtime yet?

14. Can reconstruction be implemented without modifying selectedHistory yet?

15. Can reconstruction be completed and tested independently before
    prior-lifecycle semantic context transport is designed?

16. What exact tests establish:
    - null remains null,
    - valid persisted JSON reconstructs exactly,
    - malformed persisted JSON fails closed,
    - semantic fields are not inferred,
    - input/read ordering remains stable,
    - project/conversation isolation remains intact?

Classification discipline:

Do not implement reconstruction in this unit.

Do not add investigationLifecycle to Conversation Context Runtime.

Do not add investigationLifecycle to selectedHistory.

Do not modify ollamaChat context inputs.

Do not implement cross-turn transition validation.

Do not derive semantic lifecycle facts from durableInterpretation.

Do not derive semantic lifecycle facts from reply.

Do not derive semantic lifecycle facts from supersession_status.

Do not derive semantic lifecycle facts from chronology.

Do not introduce a second semantic lifecycle schema.

Preserve the established separation:

Matilda
= semantic lifecycle authorship

Workflow
= current-turn typed transport

IEL
= persistence ownership

Future reconstruction seam
= deterministic recovery of already-authored semantic facts only

Preserve:

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

Current protected capability state:

CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH=IMPLEMENTED
IEL_LIFECYCLE_PERSISTENCE=IMPLEMENTED
IEL_LIFECYCLE_RECONSTRUCTION=ABSENT
DEDICATED_PRIOR_LIFECYCLE_CONTEXT=ABSENT
SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=ABSENT
CROSS_TURN_CONTINUITY_VALIDATION=ABSENT

Phase 1 Response Composition remains closed.

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION_READ_SEAM_EVIDENCE_COLLECTED"
echo "CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH_REMAINS_COMPLETE"
echo "IEL_LIFECYCLE_PERSISTENCE_REMAINS_IMPLEMENTED"
echo "RECONSTRUCTION_IMPLEMENTATION_NOT_STARTED"
echo "PRIOR_LIFECYCLE_CONTEXT_NOT_ADDED"
echo "CROSS_TURN_CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION_READ_SEAM"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-investigation-lifecycle-iel-reconstruction-read-seam\.sh$' ||
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

git add scripts/investigate-investigation-lifecycle-iel-reconstruction-read-seam.sh
git diff --cached --check
git commit -m "Investigate Investigation Lifecycle IEL reconstruction read seam"
git push

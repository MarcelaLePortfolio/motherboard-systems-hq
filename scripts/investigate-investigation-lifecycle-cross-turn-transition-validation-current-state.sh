#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE INVESTIGATION LIFECYCLE CROSS-TURN TRANSITION VALIDATION CURRENT STATE ==="

REQUIRED_ANCESTOR="4081391e"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: prior-context transport classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/investigate-investigation-lifecycle-cross-turn-transition-validation-current-state\.sh$|^ M scripts/investigate-investigation-lifecycle-cross-turn-transition-validation-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING PRIOR-CONTEXT CLASSIFICATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_IMPLEMENTED_AND_VALIDATED|PRIOR_LIFECYCLE_CONTEXT_TRANSPORT=IMPLEMENTED|SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=IMPLEMENTED|CROSS_TURN_TRANSITION_VALIDATION=ABSENT|NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE' \
  scripts/classify-investigation-lifecycle-prior-context-transport-implementation.sh

echo
echo "=== CURRENT BOUNDED LIFECYCLE CONTRACT ==="
grep -n -A130 -B20 \
  -E 'MatildaInvestigationLifecycleEvent|MatildaInvestigationLifecycleArtifact|validateMatildaInvestigationLifecycleArtifact' \
  scripts/utils/ollamaChat.ts |
head -n 360

echo
echo "=== CURRENT PRIOR-LIFECYCLE PROMPT CONTRACT ==="
grep -n -A40 -B15 \
  'Prior Matilda-authored Investigation Lifecycle state:' \
  scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT PRIOR-LIFECYCLE SELECTION ==="
grep -n -A40 -B10 \
  'selectMatildaPriorInvestigationLifecycle' \
  server/matilda-chat-workflow.ts

echo
echo "=== CURRENT SCOPED IEL RETRIEVAL ==="
grep -n -A130 -B15 \
  'ListInterpretationEvidenceLedgerEntriesOptions' \
  db/matilda-interpretation-runtime.ts |
head -n 210

echo
echo "=== SEARCH FOR INVESTIGATION TRANSITION RULES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'entered.*continued|continued.*advanced|advanced.*resolved|superseded|abandoned|lifecycleEvent|transition.*investigation|investigation.*transition' \
  server db scripts docs 2>/dev/null |
head -n 1600 ||
true

echo
echo "=== SEARCH FOR EXISTING TRANSITION MATRICES / VOCABULARIES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'transition matrix|allowed transition|valid transition|transition_authorization|previous_lifecycle_state|next_lifecycle_state' \
  server db scripts docs 2>/dev/null |
head -n 1600 ||
true

echo
echo "=== INSPECT GOVERNANCE LIFECYCLE IMPLEMENTATION FOR ANALOGY ONLY ==="
for file in \
  db/governance-lifecycle-composition.ts \
  db/governance-lifecycle-persistence.ts \
  server/lifecycle/production-lifecycle-consumer.test.ts \
  server/lifecycle/production-lifecycle-entry-point.test.ts \
  server/ellis/lifecycle-transition-authorization.test.ts
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    sed -n '1,360p' "$file"
  fi
done

echo
echo "=== SEARCH FOR SEMANTIC INVESTIGATION TERMINAL / CONTINUATION MEANING ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'investigationIdentity|governingQuestion|lifecycleDetermination|entered|continued|advanced|resolved|superseded|abandoned' \
  docs scripts server db 2>/dev/null |
head -n 2200 ||
true

echo
echo "=== SEARCH PHASE 2 GOVERNANCE / LINEAGE ARTIFACTS ==="
find docs scripts -type f \
  \( \
    -iname '*investigation*lifecycle*' \
    -o -iname '*phase*2*' \
    -o -iname '*lifecycle*transition*' \
  \) \
  -print 2>/dev/null |
sort

echo
echo "=== INSPECT DEFINING PHASE 2 ARTIFACTS ==="
for file in \
  scripts/define-minimum-investigation-lifecycle-transition-semantics.sh \
  scripts/classify-investigation-lifecycle-transition-semantics.sh \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh \
  scripts/classify-investigation-lifecycle-semantic-fact-representation.sh
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    grep -nE \
      'entered|continued|advanced|resolved|superseded|abandoned|transition|investigationIdentity|governingQuestion|lifecycleDetermination|Matilda|Authority' \
      "$file" |
    head -n 600 ||
    true
  fi
done

echo
echo "=== SEARCH FOR EXISTING CROSS-TURN VALIDATION ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.sh' \
  -E \
  'priorInvestigationLifecycle.*investigationLifecycle|investigationLifecycle.*priorInvestigationLifecycle|validate.*transition|transition.*validate|previous.*lifecycle.*current|current.*lifecycle.*previous' \
  server db scripts 2>/dev/null ||
true

echo
echo "=== SEARCH FOR IDENTITY CONTINUITY RULES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'same investigation|new investigation|investigation identity|investigationIdentity.*same|governingQuestion.*same|governing question' \
  docs scripts server db 2>/dev/null |
head -n 1600 ||
true

echo
echo "=== CURRENT RESPONSE VALIDATION LOCATION ==="
grep -n -A130 -B20 \
  'const result =' \
  scripts/utils/ollamaChat.ts |
head -n 260

echo
echo "=== CURRENT WORKFLOW POST-OLLAMA SEQUENCE ==="
grep -n -A130 -B20 \
  'const ollamaResult =' \
  server/matilda-chat-workflow.ts |
head -n 220

echo
echo "=== TEST SURFACE RELEVANT TO TRANSITIONS ==="
find server db scripts -type f \
  \( \
    -iname '*lifecycle*.test.ts' \
    -o -iname '*transition*.test.ts' \
    -o -iname '*prior*context*.test.ts' \
  \) \
  -print 2>/dev/null |
sort

echo
echo "=== VERIFY CURRENT IMPLEMENTED BASELINE ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts

npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-interpretation-context-runtime.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-history-selection-runtime.ts
then
  echo "STOP: production runtime changed during transition-validation investigation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-interpretation-lifecycle-provider.ts \
    server/matilda-interpretation-context-runtime.ts \
    server/matilda-conversation-context-runtime.ts \
    server/matilda-history-selection-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

cat <<'FINDINGS'

Cross-turn Investigation Lifecycle transition-validation investigation:

Protected capability state:

CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH=IMPLEMENTED
IEL_LIFECYCLE_PERSISTENCE=IMPLEMENTED
IEL_LIFECYCLE_RECONSTRUCTION=IMPLEMENTED
PRIOR_LIFECYCLE_CONTEXT_TRANSPORT=IMPLEMENTED
SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=IMPLEMENTED
CROSS_TURN_TRANSITION_VALIDATION=ABSENT

This unit must determine what deterministic validation is actually supported by
repository evidence.

Questions requiring classification:

1. Which transitions between lifecycleEvent values are explicitly supported by
   existing Phase 2 semantics?

2. Are any transitions explicitly prohibited?

3. Does lifecycle identity have to remain stable for:
   - continued,
   - advanced,
   - resolved?

4. Does entered require a new investigationIdentity relative to prior state?

5. What semantics distinguish:
   - superseded,
   - abandoned,
   - resolved?

6. Can a resolved investigation later continue or advance, or is resolved
   terminal according to repository evidence?

7. Can an abandoned investigation later continue?

8. Can a superseded investigation later continue under the same identity?

9. Does a changed governingQuestion imply:
   - a new investigation,
   - an advanced investigation,
   - supersession,
   - or no deterministic conclusion?

10. Which lifecycle constraints are semantic facts Matilda must author versus
    structural invariants runtime may validate?

11. Is transition validation best owned:
    - inside the shared lifecycle validator,
    - inside ollamaChat after current result parsing,
    - inside workflow after ollamaChat,
    - or in a dedicated deterministic transition validator?

12. Can validation compare:

    priorInvestigationLifecycle
    ->
    current investigationLifecycle

    without making runtime the semantic author?

13. If Matilda emits a structurally valid but transition-invalid artifact,
    should the system:
    - fail closed,
    - discard lifecycle only,
    - or permit it?

14. Does existing doctrine support any automatic lifecycle repair?

15. What exact validation behavior preserves one Ollama invocation without
    retries?

16. What tests are required for:
    - no prior state -> null;
    - no prior state -> entered;
    - prior state -> null;
    - continued identity preservation;
    - advanced identity preservation;
    - resolved identity preservation;
    - terminal-state behavior;
    - superseded behavior;
    - abandoned behavior;
    - changed identity behavior;
    - changed governing question behavior?

17. What is the smallest rollback-safe implementation surface if a deterministic
    transition contract is established?

Investigation discipline:

Do not infer a transition matrix from event names alone.

Do not import Governance Lifecycle transition semantics into Matilda
Investigation Lifecycle unless repository evidence explicitly establishes that
they are equivalent.

Governance lifecycle files may be inspected only as architectural analogies.

Do not allow runtime to decide that an investigation has advanced, resolved,
superseded, or been abandoned.

Those remain Matilda-authored semantic determinations.

Runtime may validate only explicit invariants supported by repository evidence.

Do not add retries.

Do not add a correction invocation.

Do not add another model invocation.

Do not alter the prior-context prompt.

Do not alter scoped IEL retrieval.

Do not alter IEL reconstruction.

Do not alter selectedHistory.

Do not alter Conversation Context Runtime.

Do not alter conversation-turn persistence.

Do not alter Living Draft behavior.

Do not reopen Phase 1 Response Composition.

Preserve:

Matilda
= Interpretation Authority and lifecycle semantic author

Runtime
= deterministic enforcement of explicit established invariants only

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE_INSPECTED"
echo "CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION=NOT_STARTED"
echo "PRIOR_LIFECYCLE_CONTEXT_TRANSPORT_REMAINS_IMPLEMENTED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-investigation-lifecycle-cross-turn-transition-validation-current-state\.sh$' ||
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
  scripts/investigate-investigation-lifecycle-cross-turn-transition-validation-current-state.sh

git diff --cached --check
git commit -m "Investigate Investigation Lifecycle cross-turn transition validation"
git push

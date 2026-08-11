#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ASSESS PHASE 2 INVESTIGATION LIFECYCLE CLOSURE ==="

REQUIRED_ANCESTOR="0f307abc"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: transition-validation classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY ASSESSMENT-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/assess-phase-2-investigation-lifecycle-closure\.sh$|^ M scripts/assess-phase-2-investigation-lifecycle-closure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "ASSESSMENT_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY CROSS-TURN VALIDATION COMPLETION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTED_AND_VALIDATED|CROSS_TURN_TRANSITION_VALIDATION=IMPLEMENTED|IMPLEMENTED_CONTINUITY_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY|MATILDA_SEMANTIC_AUTHORITY=PRESERVED|NEXT_ACTION=ASSESS_PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE' \
  scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation.sh

echo
echo "=== VERIFY PHASE 2 SEMANTIC CONTRACT ==="
grep -nE \
  'investigationIdentity must remain stable|lifecycleEvent=continued|lifecycleEvent=advanced|lifecycleEvent=resolved|lifecycleEvent=abandoned|minimum sufficient semantic contract' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh

echo
echo "=== VERIFY STRUCTURED RESPONSE CAPABILITY ==="
grep -nE \
  'MatildaInvestigationLifecycleArtifact|validateMatildaInvestigationLifecycleArtifact|validateMatildaInvestigationLifecycleContinuity|investigationLifecycle' \
  scripts/utils/ollamaChat.ts |
head -n 140

echo
echo "=== VERIFY PERSISTENCE / RECONSTRUCTION CAPABILITY ==="
grep -nE \
  'investigation_lifecycle_json|investigationLifecycle|validateMatildaInvestigationLifecycleArtifact' \
  db/matilda-interpretation-runtime.ts |
head -n 180

echo
echo "=== VERIFY PRIOR CONTEXT CAPABILITY ==="
grep -nE \
  'priorInvestigationLifecycle|selectMatildaPriorInvestigationLifecycle|scopedLifecycleLedgerEntries' \
  server/matilda-chat-workflow.ts \
  scripts/utils/ollamaChat.ts |
head -n 180

echo
echo "=== VERIFY CROSS-TURN VALIDATOR TEST SURFACE ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== VERIFY PRIOR CONTEXT REGRESSIONS ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts \
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== VERIFY PERMANENT RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== SEARCH FOR UNRESOLVED PHASE 2 RESPONSIBILITY CLAIMS ==="
grep -RInE \
  'Investigation Lifecycle.*(ABSENT|NOT_IMPLEMENTED|NOT_STARTED|MISSING)|CROSS_TURN_TRANSITION_VALIDATION=(ABSENT|DEFERRED)|NEXT_ACTION=.*INVESTIGATION_LIFECYCLE|NEXT_UNIT=.*INVESTIGATION_LIFECYCLE' \
  scripts \
  --exclude='assess-phase-2-investigation-lifecycle-closure.sh' \
  --exclude='classify-investigation-lifecycle-cross-turn-transition-validation-current-state.sh' \
  --exclude='classify-investigation-lifecycle-cross-turn-transition-validation-implementation-readiness.sh' \
  --exclude='classify-investigation-lifecycle-cross-turn-transition-validation-implementation.sh' \
  2>/dev/null ||
true

echo
echo "=== FALSIFICATION SEARCH — DISTINCT UNIMPLEMENTED PHASE 2 CAPABILITY ==="
grep -RInE \
  'Investigation Lifecycle.*(remaining gap|remaining capability|missing capability|must still|not yet established|requires another|successor corridor)' \
  docs scripts \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='assess-phase-2-investigation-lifecycle-closure.sh' \
  2>/dev/null |
tail -n 300 ||
true

cat <<'FINDINGS'

Phase 2 Investigation Lifecycle closure assessment:

Established implemented capability chain:

- minimum semantic fact contract;
- bounded lifecycle event vocabulary;
- structured Matilda-authored Investigation Lifecycle response artifact;
- fail-closed current-artifact validation;
- current-turn workflow transport;
- IEL lifecycle persistence;
- shared lifecycle semantic validator;
- IEL lifecycle reconstruction;
- project/conversation-scoped prior lifecycle retrieval;
- newest eligible prior lifecycle selection;
- dedicated prior lifecycle semantic-generation context transport;
- prior/current semantic-authority separation;
- continued/advanced cross-turn investigationIdentity continuity validation;
- fail-closed continuity mismatch behavior;
- one Ollama invocation preserved.

Closure questions:

1. Does repository evidence identify any distinct Investigation Lifecycle
   responsibility that remains required for the currently established Phase 2
   capability boundary?

2. Are broader transition-matrix rules genuinely required for Phase 2 closure,
   or are they unsupported future semantics that should remain absent?

3. Are terminal-state rules required by repository evidence, or would adding
   them invent semantics not currently governed?

4. Is exact governingQuestion equality required, or does current evidence
   correctly leave it unimplemented?

5. Does any remaining Investigation Lifecycle uncertainty materially change
   implementation direction?

6. Has the known Phase 2 capability gap identified before Subcorridor 5 now been
   closed?

Assessment discipline:

Do not treat historical scripts containing earlier ABSENT / DEFERRED states as
current capability state when later implementation and classification supersede
them.

Do not invent broader lifecycle requirements merely to extend Phase 2.

Do not reopen completed Phase 2 responsibilities without contradictory evidence.

Do not begin Phase 3 automatically.

Do not modify production runtime.

Preserve:

Matilda
= Investigation Lifecycle semantic author

Runtime
= deterministic validation, persistence, reconstruction, scoping, selection,
  and transport of explicitly established lifecycle invariants

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

ASSESSMENT_STATE=PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE_UNDER_REVIEW
PRODUCTION_IMPLEMENTATION_CHANGE=NONE
PHASE_3_ATTENTION_MANAGEMENT_NOT_STARTED

NEXT_ACTION=CLASSIFY_PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE

FINDINGS

echo
echo "PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE_ASSESSED"
echo "PRODUCTION_IMPLEMENTATION_CHANGE=NONE"
echo "PHASE_3_ATTENTION_MANAGEMENT_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_PHASE_2_INVESTIGATION_LIFECYCLE_CLOSURE"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during Phase 2 closure assessment."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY ASSESSMENT-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/assess-phase-2-investigation-lifecycle-closure\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside assessment-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "ASSESSMENT_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/assess-phase-2-investigation-lifecycle-closure.sh
git diff --cached --check
git commit -m "Assess Phase 2 Investigation Lifecycle closure"
git push

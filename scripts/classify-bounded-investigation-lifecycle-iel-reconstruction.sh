#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY BOUNDED INVESTIGATION LIFECYCLE IEL RECONSTRUCTION ==="

REQUIRED_ANCESTOR="f79e127b"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: bounded IEL reconstruction implementation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-bounded-investigation-lifecycle-iel-reconstruction\.sh$|^ M scripts/classify-bounded-investigation-lifecycle-iel-reconstruction\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY IMPLEMENTED SHARED VALIDATOR ==="
grep -n -A100 -B5 \
  'export function validateMatildaInvestigationLifecycleArtifact' \
  scripts/utils/ollamaChat.ts |
head -n 140

echo
echo "=== VERIFY OLLAMA RESPONSE PARSER USES SHARED VALIDATOR ==="
grep -n -A12 -B8 \
  'validateMatildaInvestigationLifecycleArtifact(' \
  scripts/utils/ollamaChat.ts |
head -n 80

echo
echo "=== VERIFY EXISTING IEL READER EXTENSION ==="
grep -n -A140 -B15 \
  'export type InterpretationEvidenceLedgerReadEntry' \
  db/matilda-interpretation-runtime.ts |
head -n 210

echo
echo "=== VERIFY RECONSTRUCTION CONTRACT ==="
grep -n -A35 -B5 \
  'function reconstructInvestigationLifecycle' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY EXISTING READER PROJECTS LIFECYCLE JSON ==="
reader="$(
  sed -n \
    '/export function listInterpretationEvidenceLedgerEntries/,/^}/p' \
    db/matilda-interpretation-runtime.ts
)"

printf '%s\n' "$reader"

printf '%s\n' "$reader" |
grep -q 'investigation_lifecycle_json' || {
  echo "STOP: existing IEL reader does not project lifecycle JSON."
  exit 2
}

echo "IEL_READER_LIFECYCLE_PROJECTION_CONFIRMED"

echo
echo "=== VERIFY NO PARALLEL IEL QUERY ==="
parallel="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.test.ts' \
    --exclude='*.sh' \
    'FROM matilda_interpretation_evidence_ledger' \
    db server scripts 2>/dev/null |
  grep -v 'db/matilda-interpretation-runtime.ts' ||
  true
)"

if [[ -n "$parallel" ]]; then
  echo "STOP: parallel IEL query detected:"
  printf '%s\n' "$parallel"
  exit 2
fi

echo "PARALLEL_IEL_QUERY_ABSENT"

echo
echo "=== VERIFY TARGETED RECONSTRUCTION CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts

echo
echo "=== VERIFY OLLAMA LIFECYCLE CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== VERIFY IEL PERSISTENCE CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== VERIFY WORKFLOW TRANSPORT CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== VERIFY INTERPRETATION / CONTEXT REGRESSION ==="
npx tsx --test \
  server/matilda-interpretation-context-runtime.test.ts

npx tsx --test \
  server/matilda-interpretation-lifecycle-provider.test.ts

npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY ONE OLLAMA INVOCATION ==="
ollama_fetch_count="$(
  grep -c 'fetch(' scripts/utils/ollamaChat.ts ||
  true
)"

echo "OLLAMA_FETCH_REFERENCE_COUNT=$ollama_fetch_count"

[[ "$ollama_fetch_count" -eq 1 ]] || {
  echo "STOP: one Ollama invocation seam is not preserved."
  exit 2
}

echo "ONE_OLLAMA_INVOCATION_PRESERVED"

echo
echo "=== VERIFY PRIOR-LIFECYCLE CONTEXT STILL ABSENT ==="
context_refs="$(
  grep -nE \
    'investigationLifecycle|investigation_lifecycle_json|investigationIdentity|governingQuestion|lifecycleDetermination' \
    server/matilda-conversation-context-runtime.ts ||
  true
)"

if [[ -n "$context_refs" ]]; then
  echo "STOP: prior-lifecycle context was added before reconstruction classification:"
  printf '%s\n' "$context_refs"
  exit 2
fi

echo "PRIOR_LIFECYCLE_CONTEXT_REMAINS_ABSENT"

echo
echo "=== VERIFY SELECTED HISTORY STILL LIFECYCLE-INDEPENDENT ==="
history_refs="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.sh' \
    -E 'selectedHistory.*(investigationLifecycle|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination)|(investigationLifecycle|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination).*selectedHistory' \
    server db scripts 2>/dev/null ||
  true
)"

if [[ -n "$history_refs" ]]; then
  echo "STOP: selectedHistory lifecycle transport already exists:"
  printf '%s\n' "$history_refs"
  exit 2
fi

echo "SELECTED_HISTORY_LIFECYCLE_INDEPENDENCE_CONFIRMED"

cat <<'FINDINGS'

Classification:

BOUNDED_INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION_IMPLEMENTED_AND_VALIDATED

Repository-supported determination:

1. Current-turn Investigation Lifecycle semantic generation remains implemented.

2. Matilda remains the semantic author of Investigation Lifecycle state.

3. The bounded semantic artifact contract remains:

   MatildaInvestigationLifecycleArtifact

4. A reusable deterministic validator now enforces that existing contract.

5. Ollama structured-response parsing now consumes the shared validator.

6. Existing structured-response fail-closed behavior remains intact.

7. The existing production IEL reader remains:

   listInterpretationEvidenceLedgerEntries()

8. No parallel IEL read path was introduced.

9. The existing reader now projects:

   investigation_lifecycle_json

10. The IEL read model exposes reconstructed lifecycle state as:

    investigationLifecycle:
      MatildaInvestigationLifecycleArtifact | null

11. SQL NULL reconstructs as semantic null.

12. Valid persisted lifecycle JSON is deterministically parsed and validated
    against the shared bounded lifecycle contract.

13. Malformed persisted non-null JSON fails closed.

14. Persisted JSON containing semantically invalid lifecycle state fails closed
    through the shared validator.

15. Reconstruction does not infer semantic facts from unrelated IEL fields.

16. Reconstruction therefore recovers only previously Matilda-authored semantic
    lifecycle facts.

17. IEL remains persistence owner and repository read-boundary owner.

18. The shared validator owns deterministic enforcement of the existing
    lifecycle semantic contract.

19. No second semantic lifecycle schema was introduced.

20. Conversation-turn persistence remains unchanged.

21. Conversation Context Runtime remains unchanged.

22. selectedHistory remains lifecycle-independent.

23. Prior Investigation Lifecycle state is not yet supplied to semantic
    generation.

24. Therefore IEL lifecycle reconstruction is complete, but cross-turn semantic
    continuity is not yet complete.

25. The next missing capability is transport of reconstructed prior lifecycle
    state into an appropriate bounded context surface.

26. That transport must be investigated before implementation.

27. Cross-turn transition validation must remain deferred until prior-lifecycle
    context transport is independently established.

Capability state:

CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH=IMPLEMENTED

IEL_LIFECYCLE_PERSISTENCE=IMPLEMENTED

IEL_LIFECYCLE_RECONSTRUCTION=IMPLEMENTED

REUSABLE_BOUNDED_LIFECYCLE_VALIDATOR=IMPLEMENTED

DEDICATED_PRIOR_LIFECYCLE_CONTEXT=ABSENT

SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=ABSENT

CROSS_TURN_CONTINUITY_VALIDATION=ABSENT

SECOND_MODEL_INVOCATION_REQUIRED=NO

PHASE_1_RESPONSE_COMPOSITION=CLOSED

Next canonical unit:

INVESTIGATE_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_CURRENT_STATE

The next unit is investigation only.

It must determine:

- which reconstructed lifecycle entries should be eligible for prior context;
- whether project and conversation scoping are already sufficient;
- whether chronology or lifecycle identity determines candidate selection;
- whether one prior artifact or multiple artifacts should be supplied;
- whether Conversation Context Runtime or a narrower workflow seam should own
  transport;
- whether selectedHistory should remain independent;
- how semantic generation receives prior lifecycle state without treating it as
  ordinary conversation prose;
- how Matilda retains authority to determine the current lifecycle event;
- what regression and rollback surface bounds the transport implementation.

Do not implement prior-lifecycle context in this classification unit.

Do not implement cross-turn transition validation.

Do not alter current-turn lifecycle generation.

Do not alter current-turn workflow transport.

Do not alter IEL persistence.

Do not alter IEL reconstruction.

Do not alter conversation-turn persistence.

Do not alter Living Draft behavior.

Do not reopen Response Composition.

Do not change generation policy.

Do not add retries.

Do not add another model invocation.

Preserve:

Matilda
= Interpretation Authority and lifecycle semantic author

Workflow
= current-turn typed transport

IEL
= persistence and reconstruction owner

Shared validator
= deterministic enforcement of the established semantic contract

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "BOUNDED_INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION_IMPLEMENTED_AND_VALIDATED"
echo "IEL_LIFECYCLE_RECONSTRUCTION=IMPLEMENTED"
echo "REUSABLE_BOUNDED_LIFECYCLE_VALIDATOR=IMPLEMENTED"
echo "PARALLEL_IEL_QUERY=ABSENT"
echo "NULL_POLICY=SQL_NULL_TO_SEMANTIC_NULL"
echo "MALFORMED_NON_NULL_POLICY=FAIL_CLOSED"
echo "SEMANTIC_INFERENCE=ABSENT"
echo "DEDICATED_PRIOR_LIFECYCLE_CONTEXT=ABSENT"
echo "SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=ABSENT"
echo "CROSS_TURN_CONTINUITY_VALIDATION=ABSENT"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_CURRENT_STATE"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED DURING CLASSIFICATION ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-interpretation-context-runtime.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during reconstruction classification."
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
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-bounded-investigation-lifecycle-iel-reconstruction\.sh$' ||
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
  scripts/classify-bounded-investigation-lifecycle-iel-reconstruction.sh

git diff --cached --check
git commit -m "Classify bounded Investigation Lifecycle IEL reconstruction"
git push

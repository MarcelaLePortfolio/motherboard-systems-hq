#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE BOUNDED RESPONSE IMPLEMENTATION ==="

REQUIRED_CHECKPOINT="52931b26"

if ! git merge-base --is-ancestor "$REQUIRED_CHECKPOINT" HEAD; then
  echo "STOP: HEAD does not contain bounded response implementation checkpoint $REQUIRED_CHECKPOINT."
  exit 2
fi

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-bounded-response-implementation\.sh$|^ M scripts/classify-investigation-lifecycle-bounded-response-implementation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_CLASSIFICATION_SCRIPT_ONLY"

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY INVESTIGATION LIFECYCLE CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== VERIFY FULL OLLAMA REGRESSION SUITE ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY WORKFLOW DOES NOT CONSUME LIFECYCLE ==="
if grep -n \
  'investigationLifecycle' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: workflow consumption exists unexpectedly."
  exit 2
fi

echo "WORKFLOW_CONSUMPTION_ABSENT"

echo
echo "=== VERIFY NO SERVER-SIDE LIFECYCLE INTEGRATION ==="
server_hits="$(
  grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    'investigationLifecycle' \
    server \
    2>/dev/null ||
  true
)"

if [[ -n "$server_hits" ]]; then
  echo "$server_hits"
  echo "STOP: unexpected server-side Investigation Lifecycle integration exists."
  exit 2
fi

echo "SERVER_LIFECYCLE_INTEGRATION_ABSENT"

echo
echo "=== VERIFY GENERATION POLICY UNCHANGED ==="
if git show \
  --format= \
  --unified=0 \
  "$REQUIRED_CHECKPOINT" \
  -- scripts/utils/ollamaChat.ts |
  grep -E '^\+.*\b(seed|temperature|top_p|top_k)\b'
then
  echo "STOP: bounded response implementation changed generation policy."
  exit 2
fi

echo "GENERATION_POLICY_UNCHANGED"

echo
echo "=== VERIFY ONE MODEL INVOCATION ==="
invocation_count="$(
  grep -c 'fetch(' scripts/utils/ollamaChat.ts ||
  true
)"

echo "OLLAMA_FETCH_INVOCATION_COUNT=$invocation_count"

if [[ "$invocation_count" -ne 1 ]]; then
  echo "STOP: expected exactly one Ollama fetch invocation."
  exit 2
fi

echo "ONE_OLLAMA_INVOCATION_PRESERVED"

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

cat <<'FINDINGS'

Classification:

INVESTIGATION_LIFECYCLE_BOUNDED_RESPONSE_CONTRACT_IMPLEMENTED

Repository-supported determination:

1. Investigation Lifecycle now exists as a required nullable artifact in the
   existing Matilda structured semantic response.

2. The artifact is authored within the existing single Ollama invocation.

3. Ordinary non-investigative conversation explicitly represents:

   investigationLifecycle: null

4. Non-null Investigation Lifecycle output contains the established semantic
   facts:

   investigationIdentity
   governingQuestion
   lifecycleEvent
   lifecycleDetermination

5. lifecycleEvent is bounded to:

   entered
   continued
   advanced
   resolved
   superseded
   abandoned

6. Malformed lifecycle artifacts fail closed.

7. advanced and resolved require a non-empty lifecycleDetermination.

8. investigationIdentity remains Matilda-authored semantic identity.

9. Runtime does not derive investigationIdentity from conversation or
   interpretation-entry storage identity.

10. The full Ollama regression suite passes after reconciling existing mocked
    response fixtures to the newly required nullable artifact.

11. The response-contract guard passes.

12. Production workflow behavior remains unchanged.

13. No workflow Investigation Lifecycle consumption exists.

14. No Investigation Lifecycle persistence exists.

15. No IEL extension exists.

16. No database change exists.

17. Cross-turn continuity validation remains unimplemented.

18. Generation policy remains unchanged.

19. The implementation preserves:

    one user message
    -> one workflow
    -> one Ollama invocation.

20. Phase 1 Response Composition remains closed.

21. Therefore the bounded semantic response representation is complete.

Classification:

INVESTIGATION_LIFECYCLE_RESPONSE_REPRESENTATION_COMPLETE

22. Phase 2 Investigation Lifecycle itself is not complete because the validated
    artifact is not yet consumed across the workflow boundary.

23. The next question is therefore not response representation.

24. The next question is the smallest safe deterministic workflow seam for
    receiving the Matilda-authored Investigation Lifecycle artifact without
    prematurely introducing persistence, IEL changes, or fabricated cross-turn
    continuity.

Smallest next unit:

INVESTIGATE_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_SEAM

Determine from repository evidence:

1. Where server/matilda-chat-workflow.ts currently receives OllamaChatResult.

2. Which existing artifacts are consumed immediately after the Ollama call.

3. Whether investigationLifecycle can be destructured or transported at that
   boundary without altering current reply or durableInterpretation behavior.

4. Whether initial consumption should be ephemeral only.

5. Whether any legitimate workflow consumer exists before persistence is
   designed.

6. Whether Conversation Context Runtime is the correct future transport surface.

7. Whether lifecycle continuity requires prior lifecycle context before any
   workflow consumption is useful.

8. Which component should own deterministic cross-turn validation once prior
   semantic lifecycle context exists.

9. Whether workflow consumption can be implemented independently from
   persistence.

10. What tests and rollback surface would bound the smallest implementation.

Do not implement in this unit.

Do not add persistence.

Do not extend IEL.

Do not change the database.

Do not add cross-turn continuity validation.

Do not infer lifecycle identity.

Do not infer lifecycle events.

Do not parse lifecycle semantics from durableInterpretation.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not add retries.

Do not add another model invocation.

Do not change generation policy.

Do not reopen Phase 1.

Do not reopen Adaptive Detail.

Do not reopen Evidence Composition.

Preserve:

one user message
-> one workflow
-> one Ollama invocation.

Preserve Matilda as Interpretation Authority.

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_BOUNDED_RESPONSE_CONTRACT_IMPLEMENTED"
echo "INVESTIGATION_LIFECYCLE_RESPONSE_REPRESENTATION_COMPLETE"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "PERSISTENCE_NOT_ADDED"
echo "IEL_EXTENSION_NOT_ADDED"
echo "DATABASE_CHANGE_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_WORKFLOW_CONSUMPTION_SEAM"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-bounded-response-implementation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: tracked files outside classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add \
  scripts/classify-investigation-lifecycle-bounded-response-implementation.sh

git diff --cached --check
git commit -m "Classify Investigation Lifecycle response implementation"
git push

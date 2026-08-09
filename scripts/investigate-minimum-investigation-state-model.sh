#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE PHASE 2 — MINIMUM INVESTIGATION STATE MODEL ==="

REQUIRED_ANCESTOR="dc29898c"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain Phase 2 defining-evidence checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-minimum-investigation-state-model\.sh$|^ M scripts/investigate-minimum-investigation-state-model\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_INVESTIGATION_SCRIPT_ONLY"

echo
echo "=== INTERPRETATION LIFECYCLE PRIMITIVES ==="
grep -nE \
  'unresolved_questions|lineage_references|supersession_status|interpretation_event|minimum_sufficient_context|supporting_raw_evidence|matilda_observation' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== INTERPRETATION CONTEXT RUNTIME ==="
sed -n '1,260p' server/matilda-interpretation-context-runtime.ts

echo
echo "=== AUTHORITY EVALUATION ==="
sed -n '1,240p' server/matilda-history-authority-evaluator.ts

echo
echo "=== CONTAMINATION EVALUATION ==="
sed -n '1,240p' server/matilda-history-contamination-evaluator.ts

echo
echo "=== HISTORY SELECTION ==="
sed -n '1,300p' server/matilda-history-selection-runtime.ts

echo
echo "=== CONVERSATION CONTEXT COMPOSITION ==="
sed -n '1,320p' server/matilda-conversation-context-runtime.ts

echo
echo "=== WORKFLOW LIFECYCLE OWNERSHIP ==="
grep -n -A140 -B30 \
  'interpretationLifecycleEntries' \
  server/matilda-chat-workflow.ts

echo
echo "=== UNRESOLVED QUESTION OWNERSHIP SEARCH ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'unresolved_questions' \
  server db routes scripts docs 2>/dev/null | head -n 400 || true

echo
echo "=== SUPERSESSION OWNERSHIP SEARCH ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'supersession_status|supersessionStatus|ineligible_superseded|detected_superseded_context' \
  server db routes scripts docs 2>/dev/null | head -n 400 || true

echo
echo "=== INVESTIGATION CONCEPT SEARCH ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -Ei \
  'investigation lifecycle|investigation state|active investigation|investigating|evidence.pending|investigation resolved|investigation.*supersed' \
  server db routes scripts docs 2>/dev/null | head -n 500 || true

echo
echo "=== STRUCTURED RESPONSE SEMANTIC ARTIFACTS ==="
grep -nE \
  'reply|durableInterpretation|selectedContextSegments|supportSourceReferences|evidenceSufficient|explanationStatus' \
  scripts/utils/ollamaChat.ts | head -n 240

cat <<'FINDINGS'

Repository-supported investigation:

1. Phase 2 Investigation Lifecycle must not begin by inventing a new state
   machine.

2. Existing repository primitives already represent several lifecycle-relevant
   facts:

   - durable semantic interpretation;
   - interpretation lineage;
   - supersession status;
   - authority eligibility;
   - contamination status;
   - unresolved-question storage;
   - project and conversation identity;
   - supporting evidence.

3. These primitives must be evaluated for reuse before any new persistence
   surface is proposed.

4. unresolved_questions is currently a storage surface, but the normal Matilda
   workflow persists it as null.

5. Therefore unresolved_questions does not currently constitute an active
   Investigation Lifecycle detector or controller.

6. supersession_status currently expresses interpretation authority lifecycle.

7. It must not be overloaded into investigation state unless repository evidence
   establishes semantic equivalence.

8. Authority and contamination evaluators are deterministic consumers of
   interpretation lifecycle state.

9. They may provide valid inputs to Investigation Lifecycle behavior, but they
   must not independently invent semantic investigation conclusions.

10. Living Draft unresolved-question propagation is downstream synthesis.

11. Living Draft must remain non-authoritative and must not become the owner of
    Investigation Lifecycle semantics.

12. Matilda remains Interpretation Authority.

13. The current structured semantic response must be inspected before proposing
    any extension.

14. If existing semantic artifacts already contain sufficient information to
    derive a bounded investigation state deterministically, a response-contract
    extension may be unnecessary.

15. If they do not, that gap must be explicitly established before changing the
    semantic response contract.

16. The minimum Investigation State Model must distinguish lifecycle state from:

    - ordinary conversational uncertainty;
    - unresolved package questions;
    - interpretation supersession;
    - contamination;
    - approval state;
    - execution state.

17. No state names are authorized merely because they appear plausible.

18. The next classification must determine whether the minimum model can be:

    A. derived entirely from existing lifecycle primitives;

    B. represented by a narrow extension of existing IEL lifecycle metadata;

    C. requires a dedicated Investigation Lifecycle state surface;

    D. remains unresolved because V3 methodology does not define sufficient
       transition semantics.

Required classification:

Exactly one of:

INVESTIGATION_STATE_MODEL_DERIVABLE_FROM_EXISTING_LIFECYCLE_PRIMITIVES
INVESTIGATION_STATE_MODEL_REQUIRES_NARROW_IEL_EXTENSION
INVESTIGATION_STATE_MODEL_REQUIRES_DEDICATED_RUNTIME_STATE
INVESTIGATION_STATE_MODEL_REMAINS_UNRESOLVED

No implementation is authorized.

Do not change database schema.

Do not add investigation states.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not change the structured response contract.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not move semantic authority into Living Draft.

Do not alter Response Composition.

Do not reopen Summary Composition.

Do not reopen Reasoning Composition.

Do not reopen Evidence Composition.

Do not reopen Boundary Composition.

Do not reopen Adaptive Detail Selection.

Do not pull CONVERSATION_ENGINE_GENERATION_STABILITY into Phase 2.

Do not add retries.

Do not add another model invocation.

Preserve:

one user message
-> one workflow
-> one Ollama invocation.

Preserve Matilda as Interpretation Authority.

FINDINGS

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during Investigation State Model investigation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-minimum-investigation-state-model\.sh$' ||
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
echo "MINIMUM_INVESTIGATION_STATE_MODEL_EVIDENCE_COLLECTED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_INVESTIGATION_STATE_MODEL"

git add scripts/investigate-minimum-investigation-state-model.sh
git commit -m "Investigate minimum Investigation Lifecycle state model"
git push

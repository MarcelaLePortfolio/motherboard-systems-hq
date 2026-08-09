#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== PHASE 2 — DEFINE MINIMUM INVESTIGATION LIFECYCLE TRANSITION SEMANTICS ==="

REQUIRED_ANCESTOR="e6e8d538"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain minimum Investigation State Model evidence checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/define-minimum-investigation-lifecycle-transition-semantics\.sh$|^ M scripts/define-minimum-investigation-lifecycle-transition-semantics\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_INVESTIGATION_SCRIPT_ONLY"

echo
echo "=== CURRENT INVESTIGATION STATE MODEL CLASSIFICATION ==="
if [[ -f scripts/classify-minimum-investigation-state-model.sh ]]; then
  grep -nE \
    'INVESTIGATION_STATE_MODEL_|DEFINE_MINIMUM_INVESTIGATION_LIFECYCLE_TRANSITION_SEMANTICS' \
    scripts/classify-minimum-investigation-state-model.sh || true
else
  echo "CLASSIFICATION_SCRIPT_NOT_YET_PRESENT_IN_HEAD"
fi

echo
echo "=== V3 INVESTIGATION LIFECYCLE DEFINING EVIDENCE ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'Investigation Lifecycle|investigation lifecycle|investigation state|state shift|active investigation|active question|resolution|resolved|uncertainty|evidence gathered|continue.*investigation|investigation.*continue|investigation.*close|close.*investigation' \
  docs/governance \
  scripts 2>/dev/null | head -n 700 || true

echo
echo "=== CANDIDATE INVESTIGATION STATE SHIFT OBSERVATION ==="
if [[ -f docs/governance/CANDIDATE_INVESTIGATION_STATE_SHIFT_OBSERVATION.md ]]; then
  cat docs/governance/CANDIDATE_INVESTIGATION_STATE_SHIFT_OBSERVATION.md
fi

echo
echo "=== V3 LINEAGE INVESTIGATION ==="
if [[ -f docs/governance/CANDIDATE_V3_COLLABORATION_MODE_LINEAGE_INVESTIGATION.md ]]; then
  grep -n -A12 -B12 \
    -E 'investigation lifecycle|Investigation Lifecycle|uncertainty|evidence|state' \
    docs/governance/CANDIDATE_V3_COLLABORATION_MODE_LINEAGE_INVESTIGATION.md || true
fi

echo
echo "=== EXISTING SEMANTIC AND LIFECYCLE PRIMITIVES ==="
grep -nE \
  'interpretation_event|minimum_sufficient_context|supporting_raw_evidence|matilda_observation|unresolved_questions|lineage_references|supersession_status' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== CURRENT WORKFLOW AUTHORSHIP ==="
grep -n -A70 -B15 \
  'createInterpretationEvidenceLedgerEntry' \
  server/matilda-chat-workflow.ts

echo
echo "=== AUTHORITY AND CONTAMINATION TRANSITIONS ==="
cat server/matilda-history-authority-evaluator.ts
echo
cat server/matilda-history-contamination-evaluator.ts

echo
echo "=== STRUCTURED SEMANTIC RESPONSE CONTRACT ==="
sed -n '1,230p' scripts/utils/ollamaChat.ts
sed -n '620,700p' scripts/utils/ollamaChat.ts

cat <<'FINDINGS'

Repository-supported transition-semantics investigation:

1. Investigation Lifecycle must describe a semantic investigation process, not
   merely reuse an existing field whose current meaning is different.

2. Existing repository primitives provide possible inputs to lifecycle
   decisions:

   - current user message;
   - durableInterpretation;
   - support provenance;
   - evidence sufficiency;
   - interpretation lineage;
   - supersession status;
   - authority evaluation;
   - contamination evaluation;
   - unresolved-question information when semantically authored;
   - project and conversation identity.

3. None of those primitives may independently be renamed into an investigation
   state.

4. supersession_status remains interpretation-authority lifecycle metadata.

5. unresolved_questions remains unresolved-question/package information.

6. evidenceSufficient remains support-provenance sufficiency.

7. selectedContextSegments remains Adaptive Detail semantic admission.

8. Investigation Lifecycle therefore requires its own semantic definition even
   if its eventual representation can reuse existing infrastructure.

9. The minimum lifecycle semantics must answer five transition questions:

   A. ENTRY:
      What observable semantic condition establishes that the current exchange
      has become an investigation rather than ordinary conversation?

   B. CONTINUATION:
      What condition establishes that an existing investigation remains active
      across a later user turn?

   C. ADVANCEMENT:
      What semantic event constitutes meaningful progress without falsely
      resolving the investigation?

   D. RESOLUTION:
      What condition establishes that the active investigative question has
      been sufficiently answered or determined?

   E. SUPERSESSION / ABANDONMENT:
      What condition establishes that an investigation should no longer govern
      attention because the user changed, replaced, abandoned, or invalidated
      the investigative objective?

10. These transitions must also establish semantic ownership.

11. Matilda is Interpretation Authority.

12. Therefore runtime may deterministically validate, persist, correlate, and
    consume investigation lifecycle facts, but it must not invent semantic
    conclusions that belong to Matilda.

13. Conversely, not every lifecycle transition necessarily requires a new
    model-authored state label.

14. Some transitions may be deterministic consequences of already-authored
    semantic facts once those facts and transition rules are explicit.

15. The investigation must distinguish:

    MODEL_AUTHORED_SEMANTIC_FACT

    from:

    DETERMINISTIC_RUNTIME_DERIVATION

16. ENTRY must not be inferred merely because:

    - the user asks a question;
    - evidence is insufficient;
    - Explanation Status is recommended;
    - project context was retrieved;
    - an unresolved question exists downstream.

17. CONTINUATION must not be inferred merely from conversation identity or
    chronological adjacency.

18. ADVANCEMENT must not be inferred merely because additional evidence was
    retrieved.

19. RESOLUTION must not be inferred merely because a reply was produced or
    evidenceSufficient is true.

20. SUPERSESSION / ABANDONMENT must not be conflated with interpretation
    supersession unless repository evidence establishes that the two lifecycle
    events are semantically identical.

21. A minimum Investigation Lifecycle model must preserve ordinary conversation
    as the default.

22. Investigation state therefore must be exceptional and evidence-backed,
    rather than attached to every conversation turn.

23. The smallest useful lifecycle need not model every possible investigative
    nuance.

24. It only needs enough semantics to preserve an active investigative thread
    across turns, recognize meaningful progress, recognize resolution, and stop
    carrying stale investigative attention.

25. Before choosing storage or response-contract representation, repository
    evidence must determine whether V3 methodology defines these transitions
    sufficiently.

Required classification:

Exactly one of:

INVESTIGATION_TRANSITION_SEMANTICS_DEFINED_BY_EXISTING_V3_EVIDENCE
INVESTIGATION_TRANSITION_SEMANTICS_PARTIALLY_DEFINED_REQUIRE_NARROW_RECONCILIATION
INVESTIGATION_TRANSITION_SEMANTICS_REQUIRE_NEW_ARCHITECTURAL_DEFINITION
INVESTIGATION_TRANSITION_SEMANTICS_REMAIN_UNRESOLVED

For the classification, determine:

1. Whether V3 evidence defines an observable ENTRY condition.

2. Whether V3 evidence defines cross-turn CONTINUATION.

3. Whether V3 evidence distinguishes ADVANCEMENT from mere additional context.

4. Whether V3 evidence defines RESOLUTION.

5. Whether V3 evidence defines SUPERSESSION or ABANDONMENT.

6. Whether each defined transition is owned semantically by Matilda or can be
   derived deterministically by runtime.

7. Whether the lifecycle can remain bounded to one active investigation per
   conversation, or whether repository evidence requires concurrent
   investigations.

8. Whether investigation identity requires a durable identifier distinct from
   conversation_id and interpretation_entry_id.

9. Whether existing IEL lineage can correlate the lifecycle without changing
   its authority semantics.

10. Whether the minimum state model can now be classified as:

    - derivable from existing lifecycle primitives;
    - requiring a narrow IEL extension;
    - requiring dedicated runtime state;
    - or still unresolved.

No implementation is authorized.

Do not change database schema.

Do not add investigation states.

Do not extend IEL.

Do not create a dedicated Investigation Lifecycle runtime.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not change the structured response contract.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not infer investigation state from evidenceSufficient.

Do not infer investigation state from selectedContextSegments.

Do not move semantic authority into Living Draft.

Do not reopen Response Composition.

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
  echo "STOP: production runtime changed during Investigation Lifecycle transition investigation."
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
  grep -vE '^scripts/define-minimum-investigation-lifecycle-transition-semantics\.sh$' ||
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
echo "MINIMUM_INVESTIGATION_LIFECYCLE_TRANSITION_SEMANTICS_EVIDENCE_COLLECTED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_TRANSITION_SEMANTICS"

git add scripts/define-minimum-investigation-lifecycle-transition-semantics.sh
git commit -m "Define Investigation Lifecycle transition semantics"
git push

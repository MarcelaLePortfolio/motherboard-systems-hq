#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY PHASE 1 — RESPONSE COMPOSITION STATE ==="

EXPECTED_HEAD="69a26c73"

if [[ "$(git rev-parse --short HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: HEAD no longer matches Adaptive Detail closure checkpoint $EXPECTED_HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-1-response-composition-state\.sh$|^\?\? scripts/determine-next-response-composition-corridor\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification task:

Reconcile the current Phase 1 Response Composition state using current
repository evidence rather than older status labels.

Canonical Phase 1 sequence:

1. Summary Composition
2. Reasoning Classification / Reasoning Composition
3. Evidence Composition
4. Boundary Composition
5. Adaptive Detail Selection

Current evidence:

SUMMARY COMPOSITION

- Dedicated runtime prompt contract exists in ollamaChat.ts.
- Dedicated regression test exists:
  scripts/utils/ollamaChat.summary-composition.test.ts
- Response contract guard explicitly protects Summary Composition.
- Existing governance reconciliation classifies Summary Composition as:
  IMPLEMENTED_AND_VALIDATED.

Current classification:

SUMMARY_COMPOSITION_COMPLETE


REASONING CLASSIFICATION / REASONING COMPOSITION

- Dedicated Reasoning Composition runtime contract exists.
- Dedicated regression test exists:
  scripts/utils/ollamaChat.reasoning-composition.test.ts
- Explanation Status is a schema-constrained artifact.
- Dedicated Explanation Status tests exist.
- Explicit explanation-request behavior is regression validated.
- Adaptive Detail closure validation reran these contracts successfully.
- No current evidence presented by the repository indicates an unresolved
  Reasoning Composition implementation defect.

Older reconciliation labels that predate subsequent implementation and
validation must not override newer repository evidence.

Current classification:

REASONING_COMPOSITION_COMPLETE


EVIDENCE COMPOSITION

- Structured Evidence artifact runtime exists.
- supportSourceReferences runtime exists.
- evidenceSufficient remains deterministically derived from validated support.
- Explicit evidence request behavior exists.
- Dedicated Evidence Composition closure check exists:
  scripts/run-evidence-composition-closure-check.sh
- Adaptive Detail closure validation reran structured evidence,
  evidence-sufficiency, and explicit-evidence regression tests successfully.
- Adaptive Detail closure explicitly preserves Evidence Composition semantics.

Current classification:

EVIDENCE_COMPOSITION_COMPLETE


BOUNDARY COMPOSITION

- Dedicated Boundary Composition runtime prompt contract exists.
- Dedicated regression test exists:
  scripts/utils/ollamaChat.boundary-composition.test.ts
- Boundary Composition investigation and evidence-ledger artifacts exist.
- Adaptive Detail work repeatedly preserved Boundary Composition as closed.
- Adaptive Detail closure explicitly states:
  Boundary Composition remains closed.
- No contradictory current repository evidence has been presented.

Current classification:

BOUNDARY_COMPOSITION_COMPLETE


ADAPTIVE DETAIL SELECTION

- Deterministic segmentation implemented and validated.
- Candidate transport implemented and validated.
- selectedContextSegments model-authored contract implemented.
- Exact child identity validation implemented.
- Parent support identity separation implemented.
- Mixed-content behavior validated.
- Validation-only observability and seeded diagnostic seams preserved outside
  production.
- Closure commit:
  69a26c73 Validate Adaptive Detail corridor closure
- Closure classification:
  ADAPTIVE_DETAIL_SELECTION_COMPLETE

Current classification:

ADAPTIVE_DETAIL_SELECTION_COMPLETE


PHASE 1 DETERMINATION

All five canonical Phase 1 Response Composition corridors are now supported as
complete by current repository evidence.

Therefore:

PHASE_1_RESPONSE_COMPOSITION_COMPLETE


NEXT CANONICAL PHASE

The established Matilda Collaboration Runtime sequence is:

Phase 1 — Response Composition
Phase 2 — Investigation Lifecycle
Phase 3 — Attention Management
Phase 4 — Governance

Because Phase 1 is complete, the next canonical phase is:

PHASE_2_INVESTIGATION_LIFECYCLE


DEFERRED GENERATION STABILITY

CONVERSATION_ENGINE_GENERATION_STABILITY remains a real deferred reliability
corridor.

It must not displace the canonical Matilda Collaboration Runtime sequence.

It must not reopen Adaptive Detail.

It must not silently become Phase 2.

It remains separately deferred unless explicitly prioritized.


Final classification:

PHASE_1_RESPONSE_COMPOSITION_COMPLETE

Next canonical phase:

PHASE_2_INVESTIGATION_LIFECYCLE

Smallest next unit:

RECONCILE_PHASE_2_INVESTIGATION_LIFECYCLE_CURRENT_STATE

That reconciliation should determine:

1. what Investigation Lifecycle behavior was defined by V3 methodology;
2. what repository/runtime capabilities already exist that contribute to it;
3. whether any Investigation Lifecycle capability is already implemented;
4. which capabilities remain characterized only;
5. the smallest first corridor inside Phase 2;
6. its ownership boundary;
7. validation and rollback paths;
8. whether implementation is actually required.

Do not implement Phase 2 yet.

Do not alter Response Composition.

Do not reopen Summary Composition.

Do not reopen Reasoning Composition.

Do not reopen Evidence Composition.

Do not reopen Boundary Composition.

Do not reopen Adaptive Detail Selection.

Do not pull deferred Conversation Engine generation stability into the active
canonical corridor.

Preserve:

one user message
-> one workflow
-> one Ollama invocation.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== RESPONSE COMPOSITION REGRESSION CHECK ==="
npx tsx --test \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.reasoning-composition.test.ts \
  scripts/utils/ollamaChat.boundary-composition.test.ts \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.explanation-request.test.ts \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts

echo
echo "=== EVIDENCE COMPOSITION CLOSURE CHECK ==="
if [[ -x scripts/run-evidence-composition-closure-check.sh ]]; then
  ./scripts/run-evidence-composition-closure-check.sh
else
  echo "EVIDENCE_COMPOSITION_CLOSURE_CHECK_SCRIPT_NOT_EXECUTABLE_OR_ABSENT"
fi

echo
echo "=== ADAPTIVE DETAIL CLOSURE MARKER ==="
grep -n \
  'ADAPTIVE_DETAIL_SELECTION_COMPLETE' \
  scripts/validate-adaptive-detail-corridor-closure.sh

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during Phase 1 classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi
echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "PHASE_1_RESPONSE_COMPOSITION_COMPLETE"
echo "NEXT_CANONICAL_PHASE=PHASE_2_INVESTIGATION_LIFECYCLE"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "NEXT_UNIT=RECONCILE_PHASE_2_INVESTIGATION_LIFECYCLE_CURRENT_STATE"
echo "IMPLEMENTATION_NOT_STARTED"

git add \
  scripts/determine-next-response-composition-corridor.sh \
  scripts/classify-phase-1-response-composition-state.sh

git commit -m "Classify Phase 1 Response Composition complete"
git push

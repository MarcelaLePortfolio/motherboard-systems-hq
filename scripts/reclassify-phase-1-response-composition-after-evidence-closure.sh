#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RECLASSIFY PHASE 1 — RESPONSE COMPOSITION AFTER EVIDENCE CLOSURE ==="

REQUIRED_ANCESTOR="13e565dd"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: required Evidence Composition reconciliation checkpoint is not an ancestor of HEAD."
  exit 2
fi

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/reclassify-phase-1-response-composition-after-evidence-closure\.sh$|^\?\? scripts/reclassify-phase-1-response-composition-after-evidence-closure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_RECLASSIFICATION_SCRIPT_ONLY"

cat <<'FINDINGS'

Classification:

PHASE_1_RESPONSE_COMPOSITION_COMPLETE

Repository-supported determination:

1. Phase 1 Response Composition consists of:

   - Summary Composition;
   - Reasoning Composition;
   - Evidence Composition;
   - Boundary Composition;
   - Adaptive Detail Selection.

2. Summary Composition has an established runtime contract and regression
   coverage.

Classification:

SUMMARY_COMPOSITION_COMPLETE

3. Reasoning Composition has an established runtime contract, regression
   coverage, schema-constrained Explanation Status, and validated explicit
   explanation behavior.

Classification:

REASONING_COMPOSITION_COMPLETE

4. Evidence Composition deterministically constructs Source-Excerpt evidence
   from validated project-context provenance.

5. Conversation-turn support intentionally does not construct Source-Excerpt
   evidence.

6. Invalid or unsupplied support provenance fails closed.

7. The recent live diagnostic exposed model-authored invented conversation
   provenance rather than a deterministic Evidence Composition construction
   defect.

8. That broader semantic-generation reliability concern belongs to:

   CONVERSATION_ENGINE_GENERATION_STABILITY

Classification:

EVIDENCE_COMPOSITION_COMPLETE_WITH_DEFERRED_GENERATION_STABILITY_LIMITATION

9. Boundary Composition retains its established runtime contract and regression
   coverage.

10. No contradictory evidence requires reopening it.

Classification:

BOUNDARY_COMPOSITION_COMPLETE

11. Adaptive Detail Selection has established segmentation, candidate transport,
    selected-context observation and validation, child/parent identity
    separation, mixed-content behavior, and corridor closure.

Classification:

ADAPTIVE_DETAIL_SELECTION_COMPLETE

12. All five constituent Phase 1 corridors are therefore complete.

13. The remaining model-generation reliability limitation is explicit but is
    not owned by Response Composition.

14. It remains deferred as:

    CONVERSATION_ENGINE_GENERATION_STABILITY

15. Therefore:

    PHASE_1_RESPONSE_COMPOSITION_COMPLETE

16. The next canonical phase is:

    PHASE_2_INVESTIGATION_LIFECYCLE

17. Phase 2 implementation is not authorized by this unit.

18. The next unit is collaboration/investigation only:

    RECONCILE_PHASE_2_INVESTIGATION_LIFECYCLE_CURRENT_STATE

Do not reopen a completed Phase 1 corridor without contradictory repository
evidence.

Do not alter production generation policy.

Do not add retries.

Do not add another model invocation.

Do not begin Phase 2 implementation.

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
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts

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
  echo "STOP: production runtime changed during Phase 1 reclassification."
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
  grep -vE '^scripts/reclassify-phase-1-response-composition-after-evidence-closure\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside reclassification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "RECLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "=== PHASE 1 DETERMINATION ==="
echo "SUMMARY_COMPOSITION_COMPLETE"
echo "REASONING_COMPOSITION_COMPLETE"
echo "EVIDENCE_COMPOSITION_COMPLETE_WITH_DEFERRED_GENERATION_STABILITY_LIMITATION"
echo "BOUNDARY_COMPOSITION_COMPLETE"
echo "ADAPTIVE_DETAIL_SELECTION_COMPLETE"
echo "PHASE_1_RESPONSE_COMPOSITION_COMPLETE"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "NEXT_CANONICAL_PHASE=PHASE_2_INVESTIGATION_LIFECYCLE"
echo "PHASE_2_IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=RECONCILE_PHASE_2_INVESTIGATION_LIFECYCLE_CURRENT_STATE"

git add \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

git commit -m "Confirm Phase 1 Response Composition complete"
git push

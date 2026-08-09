#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RECLASSIFY PHASE 1 — RESPONSE COMPOSITION AFTER EVIDENCE CLOSURE ==="

required_ancestor="fa2a26a7"

if ! git merge-base --is-ancestor "$required_ancestor" HEAD; then
  echo "STOP: HEAD does not contain required Evidence Composition diagnostic checkpoint $required_ancestor."
  exit 2
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "STOP: working tree is not clean."
  git status --short
  exit 2
fi

cat <<'FINDINGS'
Purpose:

Reclassify Phase 1 Response Composition only after the Evidence Composition
closure-acceptance determination has been committed.

Evidence that must be reconciled:

1. Summary Composition has established repository/runtime support.

2. Reasoning Composition has established repository/runtime support.

3. Boundary Composition has established repository/runtime support.

4. Adaptive Detail has established corridor closure.

5. Adaptive Detail closure explicitly preserves the deferred reliability
   corridor:

   CONVERSATION_ENGINE_GENERATION_STABILITY

6. Evidence Composition structural behavior is established:

   - validated project-context provenance constructs exact Source-Excerpt
     evidence;
   - conversation support does not construct Source-Excerpt evidence;
   - duplicate project-context support is deterministically deduplicated;
   - empty validated project-context support produces null evidence;
   - invalid or unsupplied provenance fails closed.

7. The latest Source-Excerpt live diagnostic did not establish an Evidence
   Composition runtime defect.

8. Instead, the model authored an unsupplied conversation support reference:

   {
     "type": "conversation_turn",
     "sourceTurnId": "1"
   }

9. Runtime correctly rejected that invented provenance.

10. Evidence Composition closure acceptance therefore distinguishes:

    deterministic Evidence Composition behavior

    from:

    broader model-authored provenance reliability.

11. Broader provenance reliability remains deferred to:

    CONVERSATION_ENGINE_GENERATION_STABILITY

12. That deferred concern must remain visible and must not be represented as
    solved.

13. It must not silently reopen Adaptive Detail.

14. It must not silently expand Evidence Composition ownership.

15. Phase 1 completion must be determined from the established ownership and
    closure state of its constituent Response Composition corridors.

Required classification:

Exactly one of:

PHASE_1_RESPONSE_COMPOSITION_COMPLETE
PHASE_1_RESPONSE_COMPOSITION_INCOMPLETE
PHASE_1_RESPONSE_COMPOSITION_STATE_REQUIRES_RECONCILIATION

If complete:

- identify the established Phase 1 constituent corridors;
- identify the deferred generation-stability limitation explicitly;
- state that the limitation does not belong to Phase 1 Response Composition;
- state that Phase 2 may become eligible to start only after a clean checkpoint
  and explicit user authorization;
- do not begin Phase 2 in this unit.

If incomplete:

- identify the exact unresolved Phase 1-owned capability;
- distinguish it from deferred Conversation Engine generation stability;
- identify the smallest remaining Phase 1 unit;
- do not begin Phase 2.

Do not implement.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not change supportSourceReferences.

Do not change selectedContextSegments.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not change Summary Composition.

Do not change Reasoning Composition.

Do not change Boundary Composition.

Do not reopen Adaptive Detail.

Do not add retries.

Do not add another model invocation.

Do not add a production seed.

Do not change model parameters.

Do not change retrieval.

Do not change segmentation.

Do not change ranking.

Do not begin Phase 2.

Preserve:

one user message -> one workflow -> one Ollama invocation.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== PHASE 1 REPOSITORY EVIDENCE ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'SUMMARY_COMPOSITION.*CLOSED|REASONING_COMPOSITION.*CLOSED|BOUNDARY_COMPOSITION.*CLOSED|ADAPTIVE_DETAIL.*CLOSED|EVIDENCE_COMPOSITION.*CLOSURE|PHASE_1_RESPONSE_COMPOSITION|CONVERSATION_ENGINE_GENERATION_STABILITY' \
  scripts docs 2>/dev/null | head -n 500 || true

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
echo "=== VERIFY PHASE 2 HAS NOT STARTED ==="
echo "PHASE_2_START=BLOCKED_DURING_RECLASSIFICATION"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "PHASE_1_RESPONSE_COMPOSITION_RECLASSIFICATION_EVIDENCE_COLLECTED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_PHASE_1_FROM_REPOSITORY_EVIDENCE"

git add scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh
git commit -m "Reclassify Phase 1 after Evidence Composition closure"
git push

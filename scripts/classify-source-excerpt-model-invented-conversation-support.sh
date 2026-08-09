#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY SOURCE-EXCERPT MODEL-INVENTED CONVERSATION SUPPORT ==="

EXPECTED_HEAD="67d94073"

if [[ "$(git rev-parse --short HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: HEAD no longer matches diagnostic checkpoint $EXPECTED_HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/validate-source-excerpt-first-live\.ts$|^\?\? scripts/classify-phase-1-response-composition-state\.sh$|^\?\? scripts/determine-next-response-composition-corridor\.sh$|^\?\? scripts/investigate-source-excerpt-live-support-source-competition\.sh$|^\?\? scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract\.sh$|^\?\? scripts/remove-stale-conversation-support-from-source-excerpt-live-fixture\.sh$|^\?\? scripts/validate-source-excerpt-first-live-contract\.test\.ts$|^\?\? scripts/classify-source-excerpt-model-invented-conversation-support\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

SOURCE_EXCERPT_LIVE_MODEL_INVENTS_CONVERSATION_SUPPORT

Repository-supported determination:

1. The current Source-Excerpt live fixture supplies no conversation history.

2. The historical sourceTurnId is absent from the active live fixture.

3. The live diagnostic observed model-authored support before deterministic
   validation.

4. Exact observed artifact:

   {
     "type": "conversation_turn",
     "sourceTurnId": "1"
   }

5. No conversation turn with sourceTurnId "1" was supplied.

6. Therefore the emitted support identity was invented by the model.

7. Runtime correctly rejected that invented provenance.

8. This is not stale serialized conversation history from the fixture.

9. This is not a deterministic support-validation defect.

10. This is not evidence that runtime should synthesize, repair, normalize, or
    silently discard model-authored provenance.

11. This is another semantic-generation provenance failure occurring before
    Evidence Composition can evaluate project-context Source-Excerpt behavior.

12. The failure class is consistent with the already-characterized broader
    Conversation Engine generation-stability concern:

    model-authored structured semantic artifacts may occasionally violate the
    supplied identity contract, while deterministic runtime correctly fails
    closed.

13. That broader concern is already deferred as:

    CONVERSATION_ENGINE_GENERATION_STABILITY

14. The existence of that deferred reliability concern must not silently reopen
    Adaptive Detail.

15. It must also not automatically redefine Evidence Composition semantics.

16. The structural Evidence Composition contract remains green.

17. The Source-Excerpt construction unit tests remain green.

18. Conversation-support separation remains green.

19. The response-contract guard remains green.

20. The unresolved question is now architectural acceptance:

    Does an intermittent model-authored invalid support reference prevent
    Evidence Composition corridor closure, or is fail-closed provenance
    enforcement sufficient for this corridor while generation reliability
    remains separately deferred?

21. That is the same class of acceptance question previously resolved for
    Adaptive Detail generation stability.

22. Do not answer that question by changing the fixture again.

23. Do not add another support source to make the model pass.

24. Do not alter production generation controls.

25. The next unit must reconcile Evidence Composition closure acceptance against
    the established generation-stability boundary.

Required next classification:

Exactly one of:

EVIDENCE_COMPOSITION_CLOSURE_ACCEPTS_FAIL_CLOSED_GENERATION_VARIANCE
EVIDENCE_COMPOSITION_REQUIRES_RELIABLE_LIVE_PROJECT_SUPPORT_SELECTION
EVIDENCE_COMPOSITION_CLOSURE_ACCEPTANCE_REQUIRES_RECONCILIATION

Do not implement.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not change the current live fixture.

Do not add history back.

Do not force project-context support.

Do not weaken support validation.

Do not repair invented provenance.

Do not add retries.

Do not add another model invocation.

Do not add a production seed.

Do not change temperature, top_p, or top_k.

Do not reopen Adaptive Detail.

Do not begin Phase 2.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== VERIFY ACTIVE LIVE FIXTURE HAS NO CONVERSATION HISTORY ==="
if grep -nE \
  'history:|sourceTurnId' \
  scripts/validate-source-excerpt-first-live.ts
then
  echo "STOP: active live fixture now contains conversation provenance."
  exit 2
fi

echo "LIVE_FIXTURE_CONVERSATION_PROVENANCE_ABSENT"

echo
echo "=== VERIFY FAIL-CLOSED CONVERSATION SUPPORT CONTRACT ==="
grep -n -A24 -B12 \
  'conversation support reference that was not supplied' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY DEFERRED GENERATION-STABILITY CLASSIFICATION ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'CONVERSATION_ENGINE_GENERATION_STABILITY|generation stability' \
  scripts docs 2>/dev/null | head -n 200 || true

echo
echo "=== VERIFY EVIDENCE STRUCTURAL CONTRACT REMAINS GREEN ==="
npx tsx --test \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during classification."
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
echo "SOURCE_EXCERPT_LIVE_MODEL_INVENTS_CONVERSATION_SUPPORT"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "PHASE_1_COMPLETION=NOT_YET_ESTABLISHED"
echo "PHASE_2_START=BLOCKED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=RECONCILE_EVIDENCE_COMPOSITION_CLOSURE_ACCEPTANCE_AGAINST_GENERATION_STABILITY_BOUNDARY"

git add \
  scripts/classify-source-excerpt-model-invented-conversation-support.sh

git commit -m "Classify invented Source-Excerpt conversation support"
git push

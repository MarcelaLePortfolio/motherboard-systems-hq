#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== VALIDATE ADAPTIVE DETAIL — CORRIDOR CLOSURE ==="

EXPECTED_HEAD="38a43c87"

if [[ "$(git rev-parse --short HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: HEAD no longer matches production-stability acceptance checkpoint $EXPECTED_HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-adaptive-detail-corridor-closure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== 1. DETERMINISTIC SEGMENTATION ==="
npx tsx --test \
  server/matilda-project-context-retrieval.segmentation.test.ts \
  server/matilda-project-context-retrieval.segment-parent-identity.test.ts \
  server/matilda-project-context-retrieval.range-metadata.test.ts

echo
echo "=== 2. CANDIDATE TRANSPORT / CONTEXT ==="
npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts \
  server/matilda-project-context-retrieval.test.ts

echo
echo "=== 3. SELECTED CONTEXT MODEL-AUTHORED CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.selected-context-observer.test.ts \
  scripts/utils/ollamaChat.child-identity-presentation.test.ts

echo
echo "=== 4. SUPPORT / MEMBERSHIP FAIL-CLOSED CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-validation-observer.test.ts \
  scripts/utils/ollamaChat.parent-support-identity-prompt.test.ts

echo
echo "=== 5. EVIDENCE COMPOSITION CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts

echo
echo "=== 6. RESPONSE COMPOSITION REGRESSIONS ==="
npx tsx --test \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.reasoning-composition.test.ts \
  scripts/utils/ollamaChat.boundary-composition.test.ts \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.explanation-request.test.ts

echo
echo "=== 7. VALIDATION-ONLY SEED CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.validation-seed.test.ts

echo
echo "=== 8. MIXED-CONTENT VALIDATION CRITERIA ==="
npx tsx --test \
  scripts/validate-adaptive-detail-mixed-content-criteria.test.ts

echo
echo "=== 9. RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== 10. VERIFY PRODUCTION WORKFLOW DOES NOT USE VALIDATION OBSERVERS ==="
if grep -n -E \
  'observeValidatedSelectedContextSegments|observeParsedSupportSourceReferences' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow uses validation-only observer seam."
  exit 2
fi
echo "PRODUCTION_WORKFLOW_OBSERVERS_ABSENT"

echo
echo "=== 11. VERIFY PRODUCTION WORKFLOW DOES NOT USE VALIDATION SEED ==="
if grep -n \
  'validationGenerationSeed' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow supplies validation-only generation seed."
  exit 2
fi
echo "PRODUCTION_WORKFLOW_SEED_ABSENT"

echo
echo "=== 12. VERIFY NO PRODUCTION SAMPLING POLICY INTRODUCED ==="
if grep -n -E \
  'temperature:|top_p:|top_k:|validationGenerationSeed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains sampling policy."
  exit 2
fi
echo "PRODUCTION_SAMPLING_POLICY_UNCHANGED"

echo
echo "=== 13. VERIFY ONE MODEL INVOCATION SEAM ==="
fetch_count="$(
  grep -c \
    'const response = await fetch' \
    scripts/utils/ollamaChat.ts || true
)"

if [[ "$fetch_count" -ne 1 ]]; then
  echo "STOP: expected exactly one Ollama fetch invocation seam; found $fetch_count."
  exit 2
fi
echo "ONE_OLLAMA_INVOCATION_SEAM_CONFIRMED"

echo
echo "=== 14. VERIFY NO SEMANTIC POST-FILTERING AUTHORITY ==="
if grep -n -E \
  'filter.*material|material.*filter|semantic.*filter|filter.*semantic' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: possible workflow semantic post-filtering detected."
  exit 2
fi
echo "NO_WORKFLOW_SEMANTIC_POST_FILTERING_DETECTED"

echo
echo "=== 15. VERIFY SELECTED CONTEXT IS NOT PERSISTED ==="
if grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'selectedContextSegments.*(insert|persist|save|write)|(?:insert|persist|save|write).*selectedContextSegments' \
  server db routes 2>/dev/null
then
  echo "STOP: selectedContextSegments persistence candidate detected."
  exit 2
fi
echo "SELECTED_CONTEXT_SEGMENTS_NON_PERSISTENT"

echo
echo "=== 16. VERIFY RESULT CONTRACT REMAINS UNWIDENED ==="
result_contract="$(
  sed -n \
    '/export interface OllamaChatResult {/,/^}/p' \
    scripts/utils/ollamaChat.ts
)"

printf '%s\n' "$result_contract"

if printf '%s\n' "$result_contract" |
  grep -q 'selectedContextSegments'
then
  echo "STOP: OllamaChatResult exposes selectedContextSegments."
  exit 2
fi
echo "OLLAMA_CHAT_RESULT_SELECTED_CONTEXT_ABSENT"

echo
echo "=== 17. VERIFY DEFERRED GENERATION-STABILITY LIMITATION RECORDED ==="
if ! grep -q \
  'ADAPTIVE_DETAIL_GENERATION_STABILITY_BELONGS_TO_SEPARATE_CORRIDOR' \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh
then
  echo "STOP: generation-stability deferral classification is missing."
  exit 2
fi

if ! grep -q \
  'Unseeded model-authored support provenance has demonstrated intermittent' \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh
then
  echo "STOP: intermittent fail-closed limitation is not explicitly recorded."
  exit 2
fi
echo "GENERATION_STABILITY_LIMITATION_EXPLICITLY_DEFERRED"

echo
echo "=== 18. VERIFY SEEDED EVIDENCE REMAINS VALIDATION-ONLY ==="
if ! grep -q \
  'validationGenerationSeed' \
  scripts/validate-adaptive-detail-mixed-content-seeded-live.ts
then
  echo "STOP: seeded validation artifact no longer uses validation-only seed seam."
  exit 2
fi

if grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'validationGenerationSeed' \
  server routes db 2>/dev/null
then
  echo "STOP: validation-only seed appears in production runtime surfaces."
  exit 2
fi
echo "SEEDED_DIAGNOSTIC_REMAINS_VALIDATION_ONLY"

echo
echo "=== 19. DIFF CHECK ==="
git diff --check

echo
echo "=== ADAPTIVE DETAIL CLOSURE DETERMINATION ==="
cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_CORRIDOR_CLOSURE_VALIDATED

Verified closure state:

1. Deterministic project-context segmentation is implemented and regression
   validated.

2. Exact child source ranges and parent excerpt lineage are preserved.

3. Segment candidates are transported through Conversation Context without
   changing public project-context excerpt semantics.

4. selectedContextSegments remains authored by Matilda in the existing single
   semantic invocation.

5. selectedContextSegments identities are deterministically validated against
   the supplied child candidate universe.

6. Invalid or invented child identities fail closed.

7. supportSourceReferences remains independently model-authored support
   provenance.

8. Project-context support continues to use supplied parent Source identities.

9. Invalid or unsupplied support identities fail closed.

10. Parent support remains consistent with selected supplied children when
    segment candidates exist for that parent.

11. Evidence Composition remains parent-excerpt based.

12. evidenceSufficient remains support-driven.

13. Mixed-content behavior has demonstrated that unrelated colocated detail can
    remain absent from the immediate reply.

14. The child/parent identity presentation collision was separated without
    changing runtime identity semantics.

15. Validation-only selected-context and parsed-support observers remain absent
    from the production workflow.

16. Validation-only generation seed support remains absent from the production
    workflow.

17. No production default seed exists.

18. No production temperature, top_p, or top_k policy was introduced.

19. Seeded reproducibility evidence remains diagnostic evidence only.

20. One user message -> one workflow -> one Ollama invocation remains intact.

21. No second semantic author was introduced.

22. No runtime semantic post-filtering authority was introduced.

23. selectedContextSegments remains non-persistent.

24. OllamaChatResult remains unwidened with respect to selectedContextSegments.

25. Matilda remains Interpretation Authority.

26. Boundary Composition remains closed.

27. The known limitation remains explicit:

    Unseeded model-authored support provenance has demonstrated intermittent
    invalid identity generation.

28. Deterministic runtime validation rejects that invalid output fail-closed.

29. Broader semantic-generation stability and production sampling policy are
    deferred to a separate Conversation Engine generation-stability/reliability
    corridor.

30. That deferred generation-policy concern does not reopen Adaptive Detail.

Closure classification:

ADAPTIVE_DETAIL_SELECTION_COMPLETE

Deferred successor corridor:

CONVERSATION_ENGINE_GENERATION_STABILITY

No additional Adaptive Detail runtime implementation is authorized by this
closure.

Next architectural action:

Return to Phase 1 Response Composition and determine the next unresolved
corridor after Adaptive Detail Selection according to the established
Response Composition sequence and repository capability state.
FINDINGS

echo
echo "ADAPTIVE_DETAIL_CORRIDOR_CLOSURE_VALIDATED"
echo "ADAPTIVE_DETAIL_SELECTION_COMPLETE"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "RUNTIME_IMPLEMENTATION_COMPLETE=true"
echo "NEXT_ACTION=DETERMINE_NEXT_RESPONSE_COMPOSITION_CORRIDOR"

git add scripts/validate-adaptive-detail-corridor-closure.sh
git commit -m "Validate Adaptive Detail corridor closure"
git push

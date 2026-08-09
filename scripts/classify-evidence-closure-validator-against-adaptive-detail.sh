#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY EVIDENCE CLOSURE VALIDATOR AGAINST CURRENT ADAPTIVE DETAIL CONTRACT ==="

cat <<'FINDINGS'
Classification:

EVIDENCE_COMPOSITION_LIVE_VALIDATOR_STALE_AGAINST_SELECTED_CONTEXT_CONTRACT

Repository-supported determination:

1. Evidence Composition structural validation passed before the live failure.

2. The response-contract guard also passed.

3. The live failure occurred during selectedContextSegments validation before
   the Source-Excerpt-first validator could evaluate Evidence Composition.

4. validate-source-excerpt-first-live.ts supplies projectContextExcerpts but
   does not supply projectContextSegmentCandidates.

5. The current ollamaChat runtime validates every model-authored
   selectedContextSegments identity against supplied
   projectContextSegmentCandidates.

6. With no supplied projectContextSegmentCandidates, the validator establishes
   an empty valid child-identity universe.

7. Any non-empty selectedContextSegments artifact authored during that
   invocation must therefore fail closed as unsupplied.

8. Repository history shows that the Source-Excerpt-first live validator
   predates the Adaptive Detail child-candidate and selected-context contract.

9. The current Adaptive Detail live validator demonstrates the newer invocation
   shape by supplying explicit projectContextSegmentCandidates.

10. Therefore the observed failure is evidence that the historical Evidence
    Composition live validator is stale against the current selected-context
    invocation contract.

11. It is not presently evidence of an Evidence Composition runtime regression.

12. It is not evidence that selectedContextSegments validation should be
    weakened.

13. Runtime correctly failed closed against the invocation it received.

14. The smallest safe next unit is validation-only reconciliation of the
    Source-Excerpt-first live validator.

15. That reconciliation should preserve the existing parent repository excerpt
    while supplying an exact child candidate for the repository evidence being
    presented to Matilda.

16. Production runtime behavior must remain unchanged.

17. Evidence Composition semantics must remain unchanged.

18. Phase 1 completion remains unestablished until the reconciled Evidence
    Composition closure check passes.

19. Phase 2 must remain blocked until Phase 1 completion is established.

Next unit:

RECONCILE_SOURCE_EXCERPT_LIVE_VALIDATOR_WITH_SELECTED_CONTEXT_CONTRACT

Authorized scope:

- change validation artifacts only;
- preserve the existing parent projectContextExcerpt;
- supply an exact projectContextSegmentCandidates child for that evidence;
- preserve the parent Source identity:
  server/matilda-chat-workflow.ts:155;
- preserve the exact supplied excerpt;
- preserve existing Source-Excerpt-first evidence assertions;
- add narrow validation coverage for the reconciled invocation shape;
- rerun Evidence Composition structural validation;
- rerun the response-contract guard;
- rerun the Evidence Composition live closure check.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not weaken selectedContextSegments validation.

Do not remove selectedContextSegments from the response contract.

Do not synthesize or repair model-authored selections.

Do not change supportSourceReferences.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not add retries.

Do not add another model invocation.

Do not add a production seed.

Do not change model parameters.

Do not change retrieval.

Do not change segmentation.

Do not change ranking.

Do not reopen Adaptive Detail.

Do not begin Phase 2.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY SOURCE-EXCERPT VALIDATOR HAS NO CHILD CANDIDATES ==="
if grep -n \
  'projectContextSegmentCandidates' \
  scripts/validate-source-excerpt-first-live.ts
then
  echo "STOP: validator already supplies child candidates; classification must be reconsidered."
  exit 2
fi
echo "SOURCE_EXCERPT_VALIDATOR_CHILD_CANDIDATES_ABSENT"

echo
echo "=== VERIFY CURRENT RUNTIME CHILD VALIDATION CONTRACT ==="
grep -nE \
  'suppliedSegmentCandidates|projectContextSegmentCandidates|suppliedSegmentByIdentity|selected context segment that was not supplied' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY CURRENT ADAPTIVE DETAIL INVOCATION SHAPE ==="
grep -n -A5 -B2 \
  'projectContextSegmentCandidates' \
  scripts/validate-adaptive-detail-mixed-content-live.ts

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
echo "EVIDENCE_COMPOSITION_LIVE_VALIDATOR_STALE_AGAINST_SELECTED_CONTEXT_CONTRACT"
echo "PHASE_1_COMPLETION=NOT_YET_ESTABLISHED"
echo "PHASE_2_START=BLOCKED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=RECONCILE_SOURCE_EXCERPT_LIVE_VALIDATOR_WITH_SELECTED_CONTEXT_CONTRACT"

git add scripts/classify-evidence-closure-validator-against-adaptive-detail.sh
git commit -m "Classify stale Evidence Composition live validator"
git push

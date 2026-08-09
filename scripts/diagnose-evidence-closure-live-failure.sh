#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== DIAGNOSE EVIDENCE COMPOSITION — LIVE CLOSURE FAILURE ==="

expected_head="69a26c73"

if [[ "$(git rev-parse --short HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Adaptive Detail closure checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-1-response-composition-state\.sh$|^\?\? scripts/determine-next-response-composition-corridor\.sh$|^\?\? scripts/diagnose-evidence-closure-live-failure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Observed result:

1. Phase 1 classification reached the Evidence Composition closure check.

2. Evidence Composition structural validation passed:

   - 27 tests passed;
   - 0 failed.

3. The response-contract guard passed.

4. The live Source-Excerpt-first validation then failed before Evidence
   Composition closure could be recorded.

5. Exact failure:

   Ollama returned a selected context segment that was not supplied in this
   invocation.

6. The failure originated from selectedContextSegments validation in
   ollamaChat.ts.

7. Therefore the observed failure is not presently evidence of:

   - malformed Evidence output;
   - invalid supportSourceReferences validation;
   - incorrect evidenceSufficient derivation;
   - Source-Excerpt construction failure.

8. It is a live model-authored selectedContextSegments contract failure.

9. Adaptive Detail recently established that selectedContextSegments is
   model-authored semantic admission metadata and must match supplied child
   identities exactly.

10. Runtime correctly fails closed when the model emits an unsupplied child.

11. That fail-closed behavior must not be weakened merely to make the older
    Evidence Composition live validator pass.

12. The Evidence Composition live validator may predate the finalized Adaptive
    Detail child-candidate contract.

13. Alternatively, the validator may already supply valid child candidates and
    this may be another intermittent model-generation failure.

14. Those possibilities must be distinguished from repository evidence before
    any implementation is authorized.

15. The prior Phase 1 completion classification must not be committed as an
    established architectural fact while this closure check remains unresolved.

16. Phase 2 Investigation Lifecycle must not begin yet.

Investigation objective:

Determine exactly why validate-source-excerpt-first-live.ts produced an
unsupplied selectedContextSegments identity under the current runtime.

Required questions:

A. Does validate-source-excerpt-first-live.ts supply
   projectContextSegmentCandidates?

B. If yes, what exact child identities are supplied?

C. What selectedContextSegments identity did the model actually emit?

D. Does the live validator use a fixture or invocation shape that predates
   Adaptive Detail candidate transport?

E. Does run-evidence-composition-closure-check.sh still encode assumptions from
   before selectedContextSegments became part of the structured response?

F. Is the failure deterministic under the validator's current invocation, or
   compatible with the already-characterized model-generation variability?

G. Can the Evidence Composition closure check be reconciled to the current
   runtime contract without changing production behavior?

H. Is Evidence Composition itself still behaviorally unclosed, or is only its
   historical closure validator stale?

Do not implement a fix in this unit.

Do not change ollamaChat.ts.

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
echo "=== SOURCE-EXCERPT LIVE VALIDATOR ==="
sed -n '1,260p' scripts/validate-source-excerpt-first-live.ts

echo
echo "=== EVIDENCE COMPOSITION CLOSURE RUNNER ==="
sed -n '1,320p' scripts/run-evidence-composition-closure-check.sh

echo
echo "=== SELECTED CONTEXT VALIDATION REGION ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '700,770p'

echo
echo "=== LIVE VALIDATOR — CANDIDATE / SELECTION REFERENCES ==="
grep -nE \
  'projectContextSegmentCandidates|selectedContextSegments|sourceStartLine|sourceEndLine|relativePath' \
  scripts/validate-source-excerpt-first-live.ts || true

echo
echo "=== CURRENT ADAPTIVE DETAIL LIVE VALIDATOR ==="
sed -n '1,260p' scripts/validate-adaptive-detail-mixed-content-live.ts

echo
echo "=== COMPARE LIVE VALIDATOR INVOCATION SHAPES ==="
diff -u \
  scripts/validate-source-excerpt-first-live.ts \
  scripts/validate-adaptive-detail-mixed-content-live.ts || true

echo
echo "=== HISTORY — SOURCE-EXCERPT LIVE VALIDATOR ==="
git log --oneline --follow -- \
  scripts/validate-source-excerpt-first-live.ts

echo
echo "=== HISTORY — EVIDENCE CLOSURE RUNNER ==="
git log --oneline --follow -- \
  scripts/run-evidence-composition-closure-check.sh

echo
echo "=== HISTORY — SELECTED CONTEXT CONTRACT ==="
git log --oneline -20 -- \
  scripts/utils/ollamaChat.ts \
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
  echo "STOP: production runtime changed during investigation."
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
echo "EVIDENCE_COMPOSITION_LIVE_CLOSURE_FAILURE_EVIDENCE_COLLECTED"
echo "PHASE_1_COMPLETION=NOT_YET_ESTABLISHED"
echo "PHASE_2_START=BLOCKED_PENDING_CLASSIFICATION"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_EVIDENCE_CLOSURE_VALIDATOR_AGAINST_CURRENT_ADAPTIVE_DETAIL_CONTRACT"

git add scripts/diagnose-evidence-closure-live-failure.sh && \
git commit -m "Diagnose Evidence Composition live closure failure" && \
git push

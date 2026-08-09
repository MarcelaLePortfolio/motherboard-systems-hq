#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — VALIDATION OBSERVABILITY SEAM INVESTIGATION ==="

if [[ "$(git rev-parse --short HEAD)" != "fdb7897f" ]]; then
  echo "STOP: HEAD no longer matches behavioral observability block checkpoint fdb7897f."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-validation-observability-seam\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== OLLAMA CONTEXT + RESULT CONTRACT ==="
sed -n '150,235p' scripts/utils/ollamaChat.ts

echo
echo "=== SELECTED SEGMENT VALIDATION ==="
sed -n '680,825p' scripts/utils/ollamaChat.ts

echo
echo "=== FINAL RESULT BOUNDARY ==="
sed -n '825,900p' scripts/utils/ollamaChat.ts

echo
echo "=== EXISTING LIVE VALIDATION PATTERNS ==="
for file in \
  scripts/validate-support-driven-source-excerpt-live.ts \
  scripts/validate-structured-evidence-object-live.ts \
  scripts/validate-source-excerpt-first-live.ts \
  scripts/validate-reasoning-composition-live.ts
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    sed -n '1,260p' "$file"
  fi
done

echo
echo "=== CONTEXT CONSTRUCTION CALL SITES ==="
grep -Rni \
  'ollamaChat(message\|ollamaChat(' \
  server scripts \
  --include='*.ts' \
  | head -n 240 || true

cat <<'QUESTIONS'

Investigate only. Do not implement.

Current requirement:

Expose the already-authored and already-deterministically-validated
selectedContextSegments artifact to bounded live validation without changing
normal production semantics.

Evaluate these candidate mechanisms:

A. Optional observer callback on OllamaChatContext.

B. Dedicated test-only wrapper around internal parse/validation logic.

C. Environment-gated diagnostic hook.

D. Widen OllamaChatResult.

Determine:

1. Which option introduces the smallest production surface.

2. Whether an optional context callback such as:

   observeValidatedSelectedContextSegments?: (
     segments: readonly MatildaSelectedContextSegment[]
   ) => void

   can remain absent from normal workflow calls.

3. Whether that callback can be invoked only after:

   - structured parsing;
   - selected identity membership validation;
   - deterministic selected identity deduplication;
   - support-source validation;
   - parent-support / child-selection consistency validation.

4. Whether invoking the observer after those checks but before the final
   OllamaChatResult return preserves the meaning "validated selection."

5. Whether the observer should receive:

   - only selectedContextSegments;
   - or selectedContextSegments plus support references.

6. Prefer the smallest payload sufficient for validation.

7. Whether the observer callback itself must be synchronous.

8. Whether callback errors should propagate or be isolated.

9. Whether allowing callback errors to affect normal runtime would violate the
   validation-only boundary.

10. Whether a validation-only observer can be typed as optional and omitted by
    server/matilda-chat-workflow.ts without any workflow changes.

11. Whether this can avoid changes to:

    - OllamaChatResult;
    - API responses;
    - IEL;
    - Living Draft;
    - persistence;
    - Evidence Composition.

12. Whether dedicated internal/test exports would create more coupling than the
    optional observer.

13. Whether environment-gated globals would introduce hidden state and should be
    rejected.

14. Whether widening OllamaChatResult would unnecessarily expose ephemeral
    semantic metadata to production consumers and should remain rejected.

15. Determine the exact test needed to prove normal behavior is unchanged when
    no observer is supplied.

16. Determine the exact test needed to prove the observer receives only
    deterministically validated and deduplicated selections.

17. Determine whether an invented selection should fail before observer
    invocation.

18. Determine whether parent-support inconsistency should fail before observer
    invocation.

19. Determine whether the observer can enable a single live validation script
    that directly records:

    - selected segment identities;
    - reply;
    - supportSourceReferences;
    - evidence;
    - evidenceSufficient;
    - durableInterpretation.

20. Confirm this still uses exactly one Ollama invocation.

21. Confirm the observer does not make semantic decisions.

22. Confirm the observer does not persist anything.

23. Confirm the observer does not alter reply text.

24. Confirm the observer does not add prompt instructions.

25. Confirm the observer does not reopen Boundary Composition.

Return exactly one classification:

ADAPTIVE_DETAIL_VALIDATION_OBSERVER_SEAM_READY
ADAPTIVE_DETAIL_VALIDATION_OBSERVER_NEEDS_RECONCILIATION
ADAPTIVE_DETAIL_VALIDATION_OBSERVABILITY_NOT_READY

Then identify exactly one next implementation unit.

Do not edit production files.

Do not edit tests.

Do not widen OllamaChatResult.

Do not modify the prompt.

Do not add persistence.

Do not add another model invocation.

Do not modify supportSourceReferences.

Do not modify Evidence Composition.

Do not modify evidenceSufficient.

Do not perform semantic post-filtering.
QUESTIONS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_VALIDATION_OBSERVABILITY_SEAM_INVESTIGATED"
echo "IMPLEMENTATION_NOT_STARTED"

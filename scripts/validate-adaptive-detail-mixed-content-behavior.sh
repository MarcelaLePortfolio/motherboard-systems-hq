#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== VALIDATE ADAPTIVE DETAIL — MIXED CONTENT BEHAVIOR ==="

if [[ "$(git rev-parse --short HEAD)" != "63b6bbd6" ]]; then
  echo "STOP: HEAD no longer matches validated selected-context contract checkpoint 63b6bbd6."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-adaptive-detail-mixed-content-behavior\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== CONTRACT SURFACE ==="
grep -n -A40 -B20 \
  -E 'selectedContextSegments|Project-context segment candidates|projectContextSegmentCandidates' \
  scripts/utils/ollamaChat.ts

echo
echo "=== EXISTING ADAPTIVE DETAIL TEST SURFACE ==="
find scripts/utils server \
  -type f \
  \( -name '*adaptive*test.ts' -o -name '*selected-context*test.ts' -o -name '*boundary-composition.test.ts' \) \
  -print | sort

cat <<'VALIDATION'

Behavioral validation target:

Verify that the new selectedContextSegments contract solves the exact mixed-content
failure that blocked Boundary Composition without introducing a second semantic
author or changing Evidence Composition.

Required scenario:

One supplied parent project-context excerpt contains two deterministic child
segments:

A. materially relevant content needed to answer the user's immediate question;

B. unrelated deferred/boundary content that should not appear in the immediate
   response.

Validate that Matilda can, in the same single Ollama invocation:

1. select child A in selectedContextSegments;

2. omit child B from selectedContextSegments;

3. compose reply using the materially relevant content;

4. omit the unrelated deferred/boundary detail from reply;

5. retain the parent excerpt as support provenance when appropriate;

6. preserve exact Source-Excerpt Evidence Composition semantics;

7. preserve evidenceSufficient semantics;

8. preserve conversation-history independence;

9. preserve durableInterpretation independence;

10. preserve one user message -> one workflow -> one Ollama invocation.

Also validate negative contract behavior:

11. an invented child identity fails closed;

12. project-context support without a selected child for a parent that has child
    candidates fails closed;

13. [] remains valid when no project context is materially required;

14. explicit evidence requests remain unchanged.

Classification must be exactly one of:

ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_SUPPORTED
ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED
ADAPTIVE_DETAIL_BEHAVIOR_VALIDATION_BLOCKED
ADAPTIVE_DETAIL_RUNTIME_REGRESSION_DETECTED

Do not change production behavior.

Do not add prompt synonyms.

Do not reopen Boundary Composition.

Do not change Evidence Composition.

Do not change supportSourceReferences.

Do not change evidenceSufficient.

Do not persist selectedContextSegments.

Do not add another model invocation.

If live Ollama behavior cannot be exercised safely from an existing repository
test seam, stop and identify the smallest missing validation seam rather than
inventing one.
VALIDATION

echo
echo "=== EXISTING SELECTED-CONTEXT / CONTRACT TESTS ==="
if [[ -f scripts/utils/ollamaChat.selected-context-segments.test.ts ]]; then
  npx tsx --test \
    scripts/utils/ollamaChat.selected-context-segments.test.ts
else
  echo "NO_DEDICATED_SELECTED_CONTEXT_TEST_FILE"
fi

echo
echo "=== FULL OLLAMA REGRESSION TESTS ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== RUNTIME VALIDATION SEAM SEARCH ==="
grep -RniE \
  'OLLAMA_BASE_URL|gemma3:4b|ollamaChat\(|semantic runtime|behavioral validation' \
  scripts server \
  --exclude='validate-adaptive-detail-mixed-content-behavior.sh' \
  | head -n 240 || true

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_MIXED_CONTENT_VALIDATION_INSPECTED"
echo "PRODUCTION_BEHAVIOR_UNCHANGED"

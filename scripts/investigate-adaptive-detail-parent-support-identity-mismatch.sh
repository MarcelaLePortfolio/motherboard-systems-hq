#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE ADAPTIVE DETAIL — PARENT SUPPORT IDENTITY MISMATCH ==="

if [[ "$(git rev-parse --short HEAD)" != "45cedd00" ]]; then
  echo "STOP: HEAD no longer matches support-validation diagnostic checkpoint 45cedd00."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-parent-support-identity-mismatch\.sh$|^\?\? scripts/run-adaptive-detail-mixed-content-live-validation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== SUPPORT PROMPT INSTRUCTIONS ==="
sed -n '610,635p' scripts/utils/ollamaChat.ts

echo
echo "=== PARENT EXCERPT SERIALIZATION ==="
sed -n '525,565p' scripts/utils/ollamaChat.ts

echo
echo "=== CHILD SEGMENT SERIALIZATION ==="
sed -n '546,575p' scripts/utils/ollamaChat.ts

echo
echo "=== SUPPORT VALIDATION ==="
sed -n '760,845p' scripts/utils/ollamaChat.ts

echo
echo "=== MIXED CONTENT LIVE FIXTURE ==="
sed -n '1,170p' scripts/validate-adaptive-detail-mixed-content-live.ts

cat <<'FINDINGS'

Observed live failure:

Model-authored support references:

[
  {
    "type": "project_context_excerpt",
    "relativePath": "docs/adaptive-detail-live-validation.md",
    "lineNumber": 20
  },
  {
    "type": "project_context_excerpt",
    "relativePath": "docs/adaptive-detail-live-validation.md",
    "lineNumber": 22
  }
]

Supplied parent support identity:

docs/adaptive-detail-live-validation.md:20

Supplied child semantic identities:

docs/adaptive-detail-live-validation.md:20-20
docs/adaptive-detail-live-validation.md:22-22

Immediate interpretation:

1. The first support reference is a valid parent identity.

2. The second support reference uses the immaterial child segment's start line
   as though it were a parent project-context support identity.

3. Runtime correctly fails closed because no supplied parent excerpt exists at
   line 22.

4. This failure occurs before the validated selected-context observer fires.

5. Therefore the live run does not yet establish whether Matilda selected:

   - only the relevant child;
   - both children;
   - neither child.

6. The selected-context semantic admission contract is therefore still
   behaviorally unclassified.

Investigation questions:

A. Does the prompt clearly distinguish:

   Parent support identity:
     Source: relativePath:parentLineNumber

   Child semantic identity:
     Segment source: relativePath:start-end

B. Does the prompt explicitly forbid using child segment line numbers as
   project_context_excerpt support lineNumber values?

C. Does the model see parentRelativePath or parentLineNumber in child candidate
   serialization?

D. Is omission of parent identity from child serialization intentional and still
   correct?

E. Could the repeated shared relativePath plus different line numbers reasonably
   lead the model to infer that each child start line is independently referenceable
   as project_context_excerpt support?

F. Would adding one narrow identity rule to the existing same invocation be
   sufficient:

   "For project_context_excerpt support, use only a Source identity shown under
   Bounded project context evidence. Never use a Segment source line range or
   child segment line number as a project_context_excerpt support identity."

G. Would that clarification preserve:

   - selectedContextSegments semantics;
   - supportSourceReferences semantics;
   - parent-excerpt Evidence Composition;
   - evidenceSufficient semantics;
   - one model invocation;
   - Matilda as semantic author?

H. Is this the first failure under the new hypothesis
   SUPPORT_PARENT_CHILD_IDENTITY_AMBIGUITY?

I. Is there any evidence of a deeper mismatch requiring runtime redesign?

Required classification:

Exactly one of:

ADAPTIVE_DETAIL_SUPPORT_PARENT_CHILD_IDENTITY_AMBIGUITY_CONFIRMED
ADAPTIVE_DETAIL_SUPPORT_CONTRACT_MISMATCH_CONFIRMED
ADAPTIVE_DETAIL_SUPPORT_IDENTITY_FAILURE_INCONCLUSIVE

If ambiguity is confirmed, identify exactly one next unit:

CLARIFY_ADAPTIVE_DETAIL_PARENT_SUPPORT_IDENTITY_PROMPT

Do not modify production code in this investigation.

Do not modify tests.

Do not change support validation.

Do not change selectedContextSegments.

Do not widen OllamaChatResult.

Do not change Evidence Composition.

Do not change evidenceSufficient.

Do not add another model invocation.

Do not add parent identity to selectedContextSegments.

Do not infer semantic selection from the failed live reply.

Do not reopen Boundary Composition.
FINDINGS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_PARENT_SUPPORT_IDENTITY_MISMATCH_INVESTIGATED"
echo "IMPLEMENTATION_NOT_STARTED"

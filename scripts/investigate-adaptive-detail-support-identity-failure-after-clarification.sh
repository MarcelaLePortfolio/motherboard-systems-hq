#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE ADAPTIVE DETAIL — SUPPORT IDENTITY FAILURE AFTER CLARIFICATION ==="

if [[ "$(git rev-parse --short HEAD)" != "8f193f1c" ]]; then
  echo "STOP: HEAD no longer matches live-validation checkpoint 8f193f1c."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-support-identity-failure-after-clarification\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== CURRENT SUPPORT INSTRUCTIONS ==="
sed -n '620,642p' scripts/utils/ollamaChat.ts

echo
echo "=== PARENT EVIDENCE SERIALIZATION ==="
sed -n '520,552p' scripts/utils/ollamaChat.ts

echo
echo "=== CHILD CANDIDATE SERIALIZATION ==="
sed -n '548,580p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT SUPPORT VALIDATION ==="
sed -n '790,842p' scripts/utils/ollamaChat.ts

cat <<'FINDINGS'

Observed behavioral rerun after prompt clarification:

Supplied parent identity:
  docs/adaptive-detail-live-validation.md:20

Supplied child identities:
  docs/adaptive-detail-live-validation.md:20-20
  docs/adaptive-detail-live-validation.md:22-22

Model-authored support identities:
  docs/adaptive-detail-live-validation.md:20
  docs/adaptive-detail-live-validation.md:22

Result:
  Runtime correctly failed closed because line 22 was not a supplied parent
  Source identity.

Hypothesis accounting:

SUPPORT_PARENT_CHILD_IDENTITY_AMBIGUITY
  Attempt 1:
    Explicitly clarified that project_context_excerpt support must use only
    Source identities from Bounded project context evidence and must never use
    Segment source line identities.

  Behavioral result:
    FAILED. The model still emitted the child line 22 as a parent support
    identity.

This is one failed implementation attempt under the current hypothesis.

Investigation questions:

A. Are parent and child identities still visually similar enough that the model
   can copy a child line number into supportSourceReferences despite the explicit
   prohibition?

B. Does the schema itself describe project_context_excerpt only as
   relativePath + lineNumber without encoding which displayed namespace that
   lineNumber belongs to?

C. Would changing child prompt serialization to an opaque semantic-selection
   identifier remove the collision without changing selectedContextSegments
   runtime identity?

D. Would adding parentRelativePath/parentLineNumber to the child prompt make the
   ambiguity worse by exposing additional parent identity inside the child block?

E. Can child segments be serialized under labels that contain no colon-style
   source identity while still giving Matilda the exact
   relativePath/sourceStartLine/sourceEndLine values required for
   selectedContextSegments?

F. Is there evidence that another wording-only prohibition would be meaningfully
   different from Attempt 1, or would that constitute speculative prompt
   layering?

G. Is the safest next hypothesis a presentation-level namespace separation,
   rather than another natural-language warning?

Required classification:

Exactly one of:

ADAPTIVE_DETAIL_SUPPORT_IDENTITY_PRESENTATION_COLLISION_CONFIRMED
ADAPTIVE_DETAIL_SUPPORT_PROMPT_NONCOMPLIANCE_CONFIRMED
ADAPTIVE_DETAIL_SUPPORT_IDENTITY_FAILURE_INCONCLUSIVE

If presentation collision is confirmed, identify exactly one proposed next unit:

SEPARATE_ADAPTIVE_DETAIL_CHILD_IDENTITY_PRESENTATION

Constraints:

- investigation only;
- do not modify ollamaChat.ts;
- do not modify tests;
- do not modify support validation;
- do not modify selectedContextSegments runtime identity;
- do not widen OllamaChatResult;
- do not change Evidence Composition;
- do not change evidenceSufficient;
- do not add another model invocation;
- do not add another wording-only prohibition;
- do not infer selected-context semantic behavior from this failed run;
- do not reopen Boundary Composition.
FINDINGS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SUPPORT_IDENTITY_FAILURE_AFTER_CLARIFICATION_INVESTIGATED"
echo "IMPLEMENTATION_NOT_STARTED"

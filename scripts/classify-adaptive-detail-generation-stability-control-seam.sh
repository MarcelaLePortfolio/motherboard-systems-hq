#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY ADAPTIVE DETAIL — GENERATION STABILITY CONTROL SEAM ==="

if [[ "$(git rev-parse --short HEAD)" != "e111e59f" ]]; then
  echo "STOP: HEAD no longer matches generation-stability investigation checkpoint e111e59f."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-adaptive-detail-generation-stability-control-seam\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_STABILITY_CONTROL_SEAM_GLOBAL_AND_HIGH_RISK

Repository-supported determination:

1. The active Matilda semantic invocation is owned by the shared
   scripts/utils/ollamaChat.ts adapter.

2. That adapter sends one request to:

   /api/generate

3. The current request body explicitly supplies:

   model
   stream
   format
   prompt

4. The repository currently supplies no generation options for:

   temperature
   seed
   top_p
   top_k

5. Therefore the current invocation inherits the active Ollama/model defaults.

6. The inspected local model reports:

   gemma3:4b

   temperature:
     1

   top_k:
     64

   top_p:
     0.95

7. The current repository therefore does not constrain sampling variance at the
   Matilda invocation seam.

8. The request payload is repository-owned and assembled immediately before the
   existing single Ollama invocation.

9. Generation options could therefore technically be introduced at this seam
   without adding another model invocation.

10. However, ollamaChat.ts is the shared semantic-generation seam rather than an
    Adaptive Detail-specific adapter.

11. The same invocation owns established semantic artifacts and composition
    behaviors including:

    - reply;
    - durableInterpretation;
    - selectedContextSegments;
    - supportSourceReferences;
    - Explanation Status;
    - Summary Composition;
    - Reasoning Composition;
    - Boundary Composition.

12. An unconditional generation-setting change in ollamaChat.ts would therefore
    alter sampling behavior across the whole Conversation Engine.

13. Existing structural regression tests do not establish semantic equivalence
    across different sampling configurations.

14. The observed intermittent :22 support-reference failure is compatible with
    sampling variance because identical bounded invocations have produced
    different support artifacts while runtime and prompt remained unchanged.

15. That compatibility is not proof that sampling configuration is the sole
    cause.

16. No repository evidence currently establishes that temperature=0, a fixed
    seed, or another particular sampling configuration would eliminate the
    invalid support behavior while preserving established semantic quality.

17. Therefore changing global generation parameters is not currently authorized.

18. A technical control seam exists, but it is global and high-risk relative to
    the current Adaptive Detail corridor.

19. The next investigation must determine whether generation controls can be
    scoped safely without fragmenting semantic ownership or introducing another
    model invocation.

Smallest next unit:

INVESTIGATE_SCOPED_MATILDA_GENERATION_CONTROL_CONTRACT

Purpose:

Determine whether generation stability controls can be introduced at a scope
that is architecturally safe and useful for the intermittent Adaptive Detail
behavior.

The investigation must determine:

1. Whether ollamaChat already has a context/config extension seam suitable for
   optional generation controls.

2. Whether such controls would represent production runtime policy or
   validation-only instrumentation.

3. Whether validation-only controls can answer production stability or only
   improve fixture reproducibility.

4. Whether repository-wide controls would require behavioral revalidation of:

   - reply;
   - durableInterpretation;
   - Summary Composition;
   - Reasoning Composition;
   - Boundary Composition;
   - Explanation Status;
   - supportSourceReferences;
   - selectedContextSegments.

5. Whether a fixed seed alone can improve reproducibility without otherwise
   changing the sampling distribution.

6. Whether temperature/top_p/top_k changes would materially alter behavior
   beyond Adaptive Detail.

7. Whether the installed Ollama API/model supports request-scoped options at the
   existing /api/generate seam.

8. Whether repository governance already defines any production generation
   policy.

9. Whether scoped controls preserve:

   one user message
   -> one workflow
   -> one Ollama invocation.

10. Whether scoped controls preserve Matilda as Interpretation Authority.

Required classification:

Exactly one of:

MATILDA_SCOPED_GENERATION_CONTROL_READY
MATILDA_VALIDATION_ONLY_GENERATION_CONTROL_READY
MATILDA_GLOBAL_GENERATION_POLICY_REQUIRES_SEPARATE_CORRIDOR
MATILDA_GENERATION_CONTROL_NOT_JUSTIFIED

Do not implement in this unit.

Do not change ollamaChat.ts.

Do not change model parameters.

Do not add retries.

Do not add another model invocation.

Do not change supportSourceReferences.

Do not change selectedContextSegments.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not change retrieval.

Do not change segmentation.

Do not change ranking.

Do not reopen Boundary Composition.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_STABILITY_CONTROL_SEAM_GLOBAL_AND_HIGH_RISK"
echo "NEXT_UNIT=INVESTIGATE_SCOPED_MATILDA_GENERATION_CONTROL_CONTRACT"
echo "IMPLEMENTATION_NOT_STARTED"

git add scripts/classify-adaptive-detail-generation-stability-control-seam.sh
git commit -m "Classify Adaptive Detail generation stability control seam"
git push

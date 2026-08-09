#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY ADAPTIVE DETAIL — LIVE STABILITY ==="

if [[ "$(git rev-parse --short HEAD)" != "6c49e9e9" ]]; then
  echo "STOP: HEAD no longer matches live-repeatability checkpoint 6c49e9e9."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-adaptive-detail-live-stability\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_PRIOR_FAILURE_INTERMITTENT_REQUIRES_STABILITY_RECONCILIATION

Repository-supported determination:

1. The current implementation has produced both:
   - a fail-closed invalid parent support identity at line 22;
   - multiple clean live runs under the same fixture and runtime.

2. The bounded three-trial repeatability probe produced:
   INVALID_PARENT_LINE_22_COUNT=0
   FAILED_CLOSED_COUNT=0
   BEHAVIOR_SUPPORTED_COUNT=3

3. Therefore the latest evidence does not support classifying the current
   implementation as consistently broken.

4. It also does not support classifying the previous invalid :22 provenance
   result as resolved.

5. The observed behavior is intermittent across independent semantic
   invocations.

6. Runtime validation remains correct:
   invalid project-context support identities fail closed.

7. No evidence supports:
   - weakening support validation;
   - deleting invalid references after generation;
   - synthesizing replacement support provenance;
   - semantic post-filtering;
   - adding another model invocation;
   - reopening Boundary Composition.

8. The current presentation separation remains plausible but not yet proven
   sufficiently stable for Adaptive Detail closure.

9. The next question is not whether the current contract is structurally valid;
   structural tests and guards already support that.

10. The next question is whether the model-authored support artifact is stable
    enough under the same bounded prompt and fixture to satisfy the production
    reliability threshold expected for this corridor.

11. A larger ad-hoc retry loop would risk turning nondeterminism into hidden
    acceptance logic and is not authorized.

12. The next investigation should instead inspect whether repository-controlled
    generation parameters or model sampling settings introduce avoidable
    nondeterminism at the single existing Ollama invocation seam.

13. This investigation must distinguish:
    - semantic variability that is intrinsic to the model;
    - repository-controlled sampling/configuration variability;
    - prompt/schema ambiguity already characterized;
    - runtime validation behavior.

14. Do not implement a fix until the repository-controlled generation
    configuration is established.

Smallest next unit:

INVESTIGATE_ADAPTIVE_DETAIL_GENERATION_STABILITY_CONTROLS

Scope:

- inspect the existing Ollama request payload;
- identify repository-controlled generation options such as temperature,
  seed, top_p, top_k, or related sampling controls;
- determine whether any are currently set;
- determine whether deterministic or lower-variance generation is already
  supported by the existing adapter/model API;
- inspect tests and prior architecture evidence for constraints on changing
  generation settings;
- determine whether such a change would affect the whole Conversation Engine
  or can be scoped safely;
- do not change runtime behavior in this unit;
- do not add retries;
- do not add another model invocation;
- do not change supportSourceReferences semantics;
- do not change selectedContextSegments semantics;
- do not change evidenceSufficient;
- do not change Evidence Composition;
- do not change retrieval, segmentation, or ranking.

Required output classification:

Exactly one of:

ADAPTIVE_DETAIL_STABILITY_CONTROL_SEAM_AVAILABLE
ADAPTIVE_DETAIL_STABILITY_CONTROL_SEAM_GLOBAL_AND_HIGH_RISK
ADAPTIVE_DETAIL_NO_REPOSITORY_CONTROLLED_STABILITY_SEAM
ADAPTIVE_DETAIL_STABILITY_CAUSE_REMAINS_UNRESOLVED
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
echo "ADAPTIVE_DETAIL_PRIOR_FAILURE_INTERMITTENT_REQUIRES_STABILITY_RECONCILIATION"
echo "NEXT_UNIT=INVESTIGATE_ADAPTIVE_DETAIL_GENERATION_STABILITY_CONTROLS"
echo "IMPLEMENTATION_NOT_STARTED"

git add scripts/classify-adaptive-detail-live-stability.sh
git commit -m "Classify Adaptive Detail live stability"
git push

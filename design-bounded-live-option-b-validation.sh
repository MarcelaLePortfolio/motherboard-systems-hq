#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DESIGN BOUNDED LIVE OPTION B VALIDATION ==="
echo "EXPECTED_HEAD_PREFIX=c44093952"
echo "IMPLEMENTATION_COMMIT=11fc6efda"
echo "AUTHORIZED_BY=415b595f5"
echo "MODE=COLLABORATION"
echo "PRODUCTION_POLICY_CHANGE=NO"
echo "GENERATION_POLICY_CHANGE=NO"
echo "VALIDATION_MODE=BOUNDED_LIVE_TYPED_INPUT"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != c44093952* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

cat > OPTION_B_LIVE_VALIDATION_DESIGN.md << 'DESIGN'
# Option B — Bounded Live Typed-Input Validation

## Purpose
Validate one real Ollama invocation using explicit typed user Package Semantics after the static and regression suite passed.

## Validation Input
Use a raw user message plus a typed `userPackageSemantics` object containing one explicit `expectedOutcome`.

The typed value must be distinctive enough that a paraphrase is visibly different from an exact match.

## Required Observation
The invocation may either:
1. succeed with `packageSemantics.expectedOutcome` exactly equal to the trimmed typed value; or
2. fail closed with the explicit Package Semantics fidelity error.

Either result demonstrates that the deterministic fidelity boundary is active.

A failure caused earlier by unrelated structured-response parsing or existing provenance validation must be classified separately and must not be treated as a fidelity failure.

## Boundaries
- one Ollama invocation only;
- unseeded production-equivalent generation;
- no retry;
- no validation seed;
- no sampling-policy change;
- no provenance weakening;
- no automatic repair;
- no second model call;
- no IEL schema change;
- no authority-model change.

## Success Criteria
The live run reaches Package Semantics fidelity enforcement and produces either:
- exact typed-value preservation and acceptance through that boundary; or
- deterministic fail-closed rejection for a mismatch.

If the run is blocked before fidelity enforcement by an unrelated existing validation boundary, live Option B validation remains inconclusive and must not be blindly repeated.

## Closure Boundary
This validation concerns Option B typed-input fidelity only.

It does not establish general unseeded production generation stability.

Package Semantics corridor closure must also account for any separately unresolved Package Semantics contract gaps.
DESIGN

echo
echo "=== DESIGN RESULT ==="
echo "LIVE_RUN_COUNT=ONE"
echo "VALIDATION_SEED=NONE"
echo "EXPECTED_OUTCOME_TYPED_INPUT=REQUIRED"
echo "EXACT_MATCH_OR_FIDELITY_FAIL_CLOSED=VALID_RESULT"
echo "UNRELATED_PRE_FIDELITY_FAILURE=INCONCLUSIVE"
echo "BLIND_RETRY=NO"
echo "UNSEEDED_PRODUCTION_STABILITY_PROOF=NO"
echo "IMPLEMENTATION_CHANGE=NONE"
echo "NEXT_ACTION=AUTHORIZE_AND_RUN_ONE_BOUNDED_LIVE_VALIDATION"

git diff --check

git add OPTION_B_LIVE_VALIDATION_DESIGN.md design-bounded-live-option-b-validation.sh
git commit -m "Design bounded live typed package semantics validation"
git push

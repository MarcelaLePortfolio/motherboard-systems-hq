#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DESIGN OPTION B RUNTIME FIDELITY INTEGRATION REPAIR ==="
echo "EXPECTED_HEAD_PREFIX=8945a036f"
echo "DEFECT_COMMIT=8945a036f6ca3901903d999add448cb89b310f42"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "SECOND_LIVE_INVOCATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 8945a036f* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

cat > OPTION_B_RUNTIME_FIDELITY_INTEGRATION_REPAIR_DESIGN.md << 'DESIGN'
# Option B Runtime Fidelity Integration Repair

## Confirmed Defect

`enforceMatildaUserPackageSemanticsFidelity` exists and its direct tests pass, but the function is not called by the `ollamaChat` runtime path.

## Repair Scope

Add exactly one runtime call:

    enforceMatildaUserPackageSemanticsFidelity(
      validatedUserPackageSemantics,
      result.packageSemantics,
    );

## Placement

The call must occur:

1. after `parseStructuredResponse(rawResponse)`, because `result.packageSemantics` must already be structurally validated;
2. before `observeValidatedPackageSemantics`, so an artifact that violates explicit typed user fidelity is never surfaced through an observer named `observeValidatedPackageSemantics`;
3. before lifecycle continuity, selected-context provenance validation, support provenance validation, or any return/persistence-capable downstream path.

The intended order is:

    parseStructuredResponse
    → enforceMatildaUserPackageSemanticsFidelity
    → observeValidatedPackageSemantics
    → remaining existing fail-closed validations

## Required Integration Tests

Add runtime-level tests around `ollamaChat`, not only direct helper tests.

Required cases:

1. Exact typed `expectedOutcome` plus matching model-authored value:
   - fidelity passes;
   - existing observer may receive the artifact;
   - normal downstream behavior continues.

2. Typed `expectedOutcome` plus non-identical model-authored value:
   - `ollamaChat` rejects with the explicit fidelity error;
   - package-semantics observer is not called;
   - selected-context provenance validation is not the reported failure even if an invalid selected segment is also present.

3. Typed `expectedOutcome` plus null `packageSemantics`:
   - fidelity fails closed before observer and provenance validation.

4. Absent or null typed input:
   - existing runtime behavior remains unchanged.

## Invariants

- one Ollama invocation remains unchanged;
- no retry;
- no prompt change;
- no typed-input contract change;
- no workflow-input change;
- no IEL schema or persistence change;
- no Living Draft change;
- no approval, canonical-package, delegation, routing, assignment, or execution authority change;
- no sampling or generation-policy change;
- no weakening of selected-context or support-provenance validation.

## Validation Before Any New Live Run

The repair must pass:

- focused runtime fidelity integration tests;
- existing Package Semantics tests;
- lifecycle regressions;
- provenance and observer regressions;
- typecheck;
- build;
- `git diff --check`.

A new live invocation is not part of this repair authorization and requires a separate decision after static and runtime integration validation passes.

## Implementation Gate

Implementation is not yet authorized.

The next action is to review this exact one-call repair design and separately authorize implementation if accepted.
DESIGN

echo
echo "=== DESIGN DETERMINATION ==="
echo "REPAIR_CALL_COUNT=ONE"
echo "PLACEMENT_AFTER_STRUCTURED_PARSE=YES"
echo "PLACEMENT_BEFORE_PACKAGE_SEMANTICS_OBSERVER=YES"
echo "PLACEMENT_BEFORE_SELECTED_CONTEXT_VALIDATION=YES"
echo "RUNTIME_INTEGRATION_TEST_REQUIRED=YES"
echo "LIVE_RETRY_INCLUDED=NO"
echo "PROMPT_CHANGE=NO"
echo "WORKFLOW_INPUT_CHANGE=NO"
echo "IEL_CHANGE=NO"
echo "AUTHORITY_MODEL_CHANGE=NO"
echo "SOURCE_IMPLEMENTATION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=REVIEW_AND_AUTHORIZE_NARROW_RUNTIME_INTEGRATION_REPAIR"

git diff --check

git add \
  OPTION_B_RUNTIME_FIDELITY_INTEGRATION_REPAIR_DESIGN.md \
  design-option-b-runtime-fidelity-integration-repair.sh

git commit -m "Design Option B runtime fidelity integration repair"
git push

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

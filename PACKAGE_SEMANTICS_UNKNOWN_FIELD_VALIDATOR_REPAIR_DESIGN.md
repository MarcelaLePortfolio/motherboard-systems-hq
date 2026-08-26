# Package Semantics Unknown-Field Validator Repair

## Confirmed Defect

The Package Semantics JSON schema declares `additionalProperties: false`, but the shared runtime validator does not reject keys outside the bounded seven-field Package Semantics contract.

Because both IEL write validation and IEL reconstruction reuse `validateMatildaPackageSemanticsArtifact`, this is one shared-validator defect rather than three separate defects.

## Existing Bounded Field Set

The only permitted keys are:

- `expectedOutcome`
- `proposedWork`
- `proposedArtifacts`
- `inScope`
- `outOfScope`
- `constraints`
- `unresolvedQuestions`

No new fields are introduced by this repair.

## Exact Repair

Inside `validateMatildaPackageSemanticsArtifact`, after the input has been established as a non-array object and before field-value normalization, define the bounded permitted key set and inspect `Object.keys(candidate)`.

For every candidate key:

- if it belongs to the existing seven-field set, continue;
- otherwise fail closed immediately.

Required failure shape:

    throw new Error(
      `${errorPrefix} unknown package semantics field ${key}.`,
    );

The validator must not silently discard, normalize away, rename, migrate, or reinterpret an unknown key.

## Ordering

The intended validator order is:

    validate object shape
    → reject unknown keys
    → validate and normalize the seven known fields
    → return bounded typed artifact

This keeps unknown-key rejection before any normalized artifact can escape the shared validator.

## Shared Boundary Effect

No direct IEL implementation change is required.

The existing boundaries already call the shared validator:

- Ollama structured-response Package Semantics parsing;
- IEL write;
- IEL reconstruction.

Therefore the shared repair must make all three boundaries fail closed on an eighth field.

## Required Tests

### Shared Package Semantics Contract

1. a valid seven-field artifact still passes;
2. an artifact containing one eighth field fails closed;
3. the failure identifies the unknown Package Semantics field;
4. known nullable fields continue to accept null;
5. existing empty-string and malformed-type failures remain unchanged.

### IEL Write

A Package Semantics artifact containing an eighth field must be rejected by the existing IEL write path through the shared validator.

No invalid JSON should be persisted.

### IEL Reconstruction

Persisted Package Semantics JSON containing an eighth field must be rejected during reconstruction through the shared validator.

The unknown field must not be silently dropped while reconstructing a typed artifact.

## Regression Requirements

The repair must preserve:

- Option B exact typed-field fidelity enforcement;
- Option B runtime fidelity ordering;
- Package Semantics observer ordering;
- Investigation Lifecycle behavior;
- one-message / one-workflow / one-Ollama invocation;
- fail-closed selected-context validation;
- fail-closed support-provenance validation;
- existing IEL ownership of persistence;
- Living Draft derivation from IEL.

Required validation:

- Package Semantics contract tests;
- Package Semantics IEL transport tests;
- Option B direct fidelity tests;
- Option B runtime integration tests;
- Package Semantics observer tests;
- lifecycle regressions;
- `npm run check`;
- `npm run build`;
- `git diff --check`.

## Explicit Non-Scope

This repair does not authorize:

- Package Semantics schema expansion;
- aliases for unknown fields;
- historical migration or backfill;
- IEL schema changes;
- workflow changes;
- prompt changes;
- Living Draft changes;
- Approvals UI changes;
- canonical-package changes;
- delegation changes;
- authority-model changes;
- generation-policy changes;
- another live Ollama invocation.

## Implementation Gate

Implementation is not yet authorized.

The next action is to review this exact shared-validator design and separately authorize the narrow implementation if accepted.

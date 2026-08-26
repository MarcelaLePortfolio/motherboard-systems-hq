# Package Semantics Option B — Typed User Input Contract

## Status
Design only. Implementation is not authorized.

## Goal
Provide deterministic preservation of explicit user-supplied Package Semantics field values while preserving raw-message transport, Matilda interpretation authority over unstructured meaning, one user message → one workflow → one Ollama invocation, fail-closed validation, the non-authoritative Living Draft, and the existing approval transition.

## Typed User Input
The workflow may receive an optional `userPackageSemantics` object containing:
- expectedOutcome
- proposedWork
- proposedArtifacts
- inScope
- outOfScope
- constraints
- unresolvedQuestions

Each field is optional and nullable. A non-null value must be trimmed, non-empty user-supplied text.

Absence of the object preserves current raw-message-only behavior. An absent or null field creates no deterministic assertion for that field.

No natural-language parsing, heuristic extraction, inferred population, or silent field synthesis may create typed user semantics.

## Authority
Typed user semantics represent explicit user intent evidence; they are not Matilda-authored interpretation.

Matilda remains responsible for authoring `packageSemantics`. For each non-null typed field, Matilda must preserve the explicit value in the corresponding output field.

Matilda may interpret fields not supplied through typed input under the existing Package Semantics contract.

Typed input grants no Living Draft, Approval, Canonical Package, Delegation, routing, assignment, or execution authority.

## Prompt Transport
The raw user message remains present.

When typed semantics exist, transport them through a dedicated prompt section identifying them as explicit user-supplied values that must be preserved in corresponding `packageSemantics` fields.

Do not merge this channel with project context, conversation history, evidence, lifecycle state, or prior Package Semantics.

## Deterministic Fidelity
After structured-response parsing and Package Semantics validation, compare each non-null typed field with its corresponding Matilda-authored field.

Require exact string equality after boundary whitespace trimming.

Do not use semantic similarity, embeddings, model judging, fuzzy matching, substring matching, or heuristic equivalence.

If any required field is null, missing, or different, fail closed before IEL persistence.

No retry, second Ollama invocation, automatic repair, or downstream overwrite is permitted.

## Nullability
The typed object remains optional and nullable. Its individual fields remain optional and nullable.

The existing nullable Matilda `packageSemantics` contract remains unchanged.

If typed input contains at least one non-null field, Matilda returning null `packageSemantics` fails fidelity validation.

Absent or null typed fields impose no equality requirement.

## Caller Boundary
Only a trusted caller boundary may populate typed fields, and only from explicitly user-supplied structured values.

Raw chat text alone must not be converted into typed fields through application heuristics.

No UI form is assumed or required by this design.

## Persistence
Do not create a second authoritative persisted copy merely to enforce fidelity.

The raw user message remains conversation evidence. The validated Matilda-authored Package Semantics remains the IEL Package Semantics artifact.

Typed-input provenance persistence, if later required, is a separate design question.

## Validation Sequence
1. Receive raw message and optional typed semantics.
2. Validate typed input locally.
3. Perform the existing single Ollama invocation.
4. Parse the structured response.
5. Validate Matilda Package Semantics.
6. Enforce exact fidelity for non-null typed fields.
7. Preserve all existing lifecycle, context, provenance, evidence, and fail-closed checks.
8. Persist only after all required validation succeeds.

Exact implementation placement must be confirmed from repository evidence before implementation.

## Required Validation
Tests must establish:
- absent/null typed input preserves existing behavior;
- typed expectedOutcome reaches the prompt;
- exact matching values pass;
- boundary whitespace normalization passes;
- null or mismatching corresponding values fail;
- semantically similar but non-identical values fail;
- omitted typed fields impose no equality requirement;
- mismatch fails before IEL persistence;
- one Ollama invocation remains;
- Package Semantics, lifecycle, and provenance regression suites pass;
- typecheck, build, and diff-check pass.

## Non-Goals
No heuristic extraction.
No second model call.
No retries.
No UI redesign.
No sidebar compactness work.
No authority change.
No historical backfill.
No production sampling-policy change.

## Implementation Gate
Implementation requires separate explicit authorization after design review.

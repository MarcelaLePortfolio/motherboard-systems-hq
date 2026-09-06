# Matilda Retrieval-Origin Production Implementation Validation

## Status

BOUNDED IMPLEMENTATION VALIDATED — UNCOMMITTED

## Objective

Implement the minimum production-safe retrieval-origin contract established by the prior offline design without changing semantic authority, candidate inclusion, candidate order, persistence, support provenance, or the one-invocation boundary.

## Implemented Contract

Project-context child candidates now preserve runtime-derived retrieval origin as:

`"lexical" | "structural"`

Origin is assigned from the actual parent retrieval path during child segmentation.

The implementation does not infer origin later from:

- file path,
- source range,
- candidate position,
- content,
- hard-coded fixture identity.

## Presentation Boundary

Matilda's project-context candidate presentation may now include:

`retrieval origin = lexical | structural`

The prompt explicitly states that retrieval origin:

- records only how runtime discovered the candidate,
- does not determine semantic relevance,
- must not by itself cause a candidate to be selected or rejected.

Matilda remains semantic-selection authority.

## Identity Boundary

Retrieval origin is not part of Matilda's model-authored `selectedContextSegments` identity contract.

That contract remains exactly:

- `relativePath`
- `sourceStartLine`
- `sourceEndLine`

No retrieval-origin field was added to the model-authored selection schema.

## Candidate-Universe Boundary

The implementation does not change:

- retrieval ranking,
- lexical top-three selection,
- structural discovery rules,
- documentation inclusion,
- source segmentation,
- candidate count,
- candidate order,
- structural excerpt ceiling,
- ordinary lexical excerpt window.

Focused validation confirmed the existing Packages ordering remained:

- CSS candidate position 0
- structurally discovered Navigation candidate position 5

## Validation

Focused test suite:

- child candidate identity presentation
- parent provenance retention
- selectedContextSegments identity stability
- retrieval-origin prompt presentation
- retrieval-origin exclusion from model-authored selection identity
- empty candidate universe behavior
- supplied candidate identity presentation
- retrieval-origin derivation
- retrieval-origin ordering neutrality
- structural Navigation retrieval
- semantic-authority preservation
- structural-unit completeness
- structural-only excerpt expansion
- ordinary lexical five-line behavior

Result:

`14 PASS / 0 FAIL`

Full TypeScript validation:

`npx tsc --noEmit`

Result:

`PASS`

## Implementation Attempts

Attempt 1 exposed one bounded type-ownership mismatch: the segmentation helper constructed the strengthened child type before retrieval origin had been attached.

No live-model call occurred.

Attempt 2 corrected ownership by supplying the parent's real retrieval origin directly to segmentation, where the child candidate is constructed.

Attempt 2 validation passed completely.

## Architectural Determination

`RETRIEVAL_ORIGIN_PRODUCTION_CONTRACT_IMPLEMENTATION_VALIDATED_OFFLINE`

The implementation preserves:

- Matilda semantic-selection authority,
- runtime-owned retrieval provenance,
- deterministic candidate ordering,
- existing candidate universe,
- existing support-provenance reconstruction,
- fail-closed selection validation,
- no post-model semantic filtering,
- no second Ollama invocation,
- no new persistence contract.

## Current Boundary

Live-model calls: NOT AUTHORIZED.

Commit: NOT AUTHORIZED.

Push: NOT AUTHORIZED.

The implementation remains in the working tree pending a recovery checkpoint and separate authorization for any version-control effects.

# Matilda Retrieval-Origin Production Contract Design

## Status

OFFLINE DESIGN COMPLETE — PRODUCTION IMPLEMENTATION NOT AUTHORIZED

## Objective

Define the minimum production-safe contract for preserving runtime-derived retrieval origin from project-context retrieval through Matilda semantic-selection presentation.

This design does not authorize implementation.

## Established Runtime Boundary

Project-context processing remains separated into three responsibilities:

1. Retrieval determines which candidate evidence is supplied.
2. Matilda determines which supplied candidate content materially affects the immediate reply.
3. Runtime validates and resolves Matilda's selected candidate identities.

Retrieval origin is runtime-owned provenance only.

It does not determine semantic relevance.

## Current Provenance Loss

The retrieval runtime already distinguishes a structurally discovered parent candidate through:

`useStructuralUnitExcerpt: true`

That marker currently affects bounded excerpt construction only.

When the parent excerpt is segmented into child candidates, lexical-versus-structural retrieval origin is discarded.

## Minimum Contract Amendment

Extend the runtime-owned child candidate contract with:

`retrievalOrigin: "lexical" | "structural"`

Each child inherits the retrieval origin of its selected parent candidate.

Required mapping:

- ordinary ranked/lexically selected parent -> `lexical`
- bounded structurally discovered parent -> `structural`

The value must be derived during candidate construction from the actual retrieval path used for that parent.

It must not be inferred later from path names, source ranges, content, candidate position, semantic characteristics, or hard-coded fixture identities.

## Semantic Authority Boundary

`retrievalOrigin` means only how runtime discovered the supplied candidate.

It must not mean relevant, preferred, authoritative, higher-confidence, automatically selected, or support-bearing.

Matilda remains solely responsible for semantic materiality.

Runtime must not:

- automatically admit structural candidates,
- suppress lexical candidates,
- reorder candidates based on origin,
- filter Matilda selections based on origin,
- assign semantic scores based on origin.

## Candidate Universe and Order

This contract amendment does not change:

- candidate retrieval limits,
- lexical ranking,
- structural discovery rules,
- document inclusion rules,
- source segmentation,
- candidate ordering,
- candidate count,
- excerpt expansion policy.

Retrieval origin is additional provenance attached to the already-selected candidate universe.

## Model Presentation

If production positional semantic-selection presentation is separately authorized, each supplied candidate may be presented as:

Candidate position = N
retrieval origin = lexical | structural
content = ...

The prompt must explicitly state that retrieval origin records only how runtime discovered the candidate and does not determine semantic relevance.

Matilda must not select or reject a candidate merely because of retrieval origin.

Candidate position remains the complete semantic-selection identity.

## Selection Identity

Retrieval origin must not become part of semantic-selection identity.

The validated positional design remains invocation-local candidate position.

Runtime resolves a selected position back to the exact supplied candidate.

Retrieval origin is descriptive provenance, not identity.

## Fail-Closed Boundary

The amendment must not weaken fail-closed behavior.

Runtime must continue to reject malformed selection artifacts, invalid positions, and selections that cannot resolve to the supplied invocation-local candidate universe.

Retrieval origin must not be model-authored.

## Support Provenance Boundary

Retrieval origin remains separate from support provenance.

Existing parent provenance reconstruction remains runtime-owned.

`retrievalOrigin` must not substitute for parent source provenance, Evidence Composition, supportSourceReferences, or evidence sufficiency.

## Persistence Boundary

Retrieval origin remains invocation-local runtime metadata.

No persistence is established or authorized for IEL, conversation turns, Living Draft, Packages, database schema, API contracts, or client state.

## One-Invocation Boundary

This design preserves:

- one user message,
- one workflow,
- one Ollama invocation,
- one IEL entry,
- one conversation turn,
- one Living Draft update.

No second semantic-selection invocation is introduced.

## Evidence Supporting the Contract

The 30x2 adversarial retrieval-origin experiment established:

Unlabeled positional control:

- material lexical candidate selected 30/30
- immaterial structural candidate selected 0/30
- fail-closed 0/30

Retrieval-origin presentation:

- material lexical candidate selected 29/30
- immaterial structural candidate selected 0/30
- fail-closed 0/30

Combined with the earlier Packages retrieval-origin experiment, this materially deconfounded the concern that Matilda simply treats `structural` as synonymous with relevant.

The evidence supports retrieval origin as a promising runtime-owned provenance signal.

It does not establish globally deterministic semantic admission.

## Minimum Production Implementation Surface

If separately authorized, the smallest expected implementation surface is:

1. Extend `MatildaProjectContextSegmentCandidate` with typed `retrievalOrigin`.
2. Assign origin during child construction from the actual selected parent candidate.
3. Extend `OllamaChatProjectContextSegmentCandidate` with the same typed field.
4. Preserve the field transparently through conversation-context and workflow transport.
5. Add retrieval-origin presentation only at the authorized semantic-selection presentation seam.
6. Preserve existing candidate inclusion, ordering, validation, support-provenance, persistence, and one-invocation boundaries.
7. Add focused tests proving provenance derivation and non-semantic behavior.

This list is a design boundary, not implementation authorization.

## Determination

`RETRIEVAL_ORIGIN_MINIMUM_PRODUCTION_CONTRACT_ESTABLISHED_OFFLINE`

Production implementation: NOT AUTHORIZED.

Live-model calls: NOT AUTHORIZED.

Production adoption: NOT AUTHORIZED.

Commit: NOT AUTHORIZED.

Push: NOT AUTHORIZED.

## Next Gate

The next step, if separately authorized, is bounded production implementation of this minimum contract with focused tests and no broader semantic-selection redesign.

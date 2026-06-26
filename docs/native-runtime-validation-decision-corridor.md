
# Native Runtime Validation Decision Corridor

## Objective

Determine the long-term validation strategy for repository components that depend on native database bindings.

This corridor exists to resolve validation architecture rather than lifecycle architecture.

## Established Findings

The Production Lifecycle Entry Point implementation was reverted.

The implementation itself was not disproven.

Instead, validation was blocked because repository dependency policy intentionally prevents `better-sqlite3` native build execution.

Planning remains valid.

## Architectural Question

Should native database validation be considered:

1. an explicitly supported repository capability,

2. an isolated infrastructure concern executed only in approved environments, or

3. a dependency that architectural unit tests should never require.

## Scope

This corridor does not authorize:

- dependency policy changes

- implementation

- runtime changes

- endpoint creation

- scheduler integration

- worker integration

- orchestration integration

- lifecycle expansion

- schema modification

## Desired Outcome

Produce a canonical validation strategy that future runtime corridors can inherit without rediscovering the same dependency-policy limitation.

## Success Criteria

- Validation responsibilities are clearly separated from implementation responsibilities.

- Native runtime expectations are explicitly documented.

- Future implementation corridors begin with an approved validation strategy.

- The same failed dependency hypothesis cannot recur.

## Current Status

Planning only.

No implementation authorization is granted by this document.


# Phase 4 — Self-Improvement Target-Relative Invariant

## Status

Canonical architectural invariant for Phase 4 — Autonomous Self-Improvement Closure.

This document preserves the meaning of self-improvement established before Phase 4 implementation begins.

## Invariant

Self-improvement remains target-relative.

The system does not require, gain, or enter a special self-improvement mode.

A governed operation constitutes self-improvement when the target of the desired and authorized change is the system's own repository.

Therefore:

- governed execution against another repository is governed execution;
- governed execution against Motherboard's own repository is self-modification / self-improvement;
- the governance and execution architecture does not change merely because the target repository is Motherboard itself.

## Authority Boundary

Self-improvement does not mean self-authorization.

Phase 4 does not authorize the system to independently:

- select its own roadmap;
- decide what it should improve;
- approve proposed changes;
- create new execution authority;
- expand an approved execution scope;
- grant itself commit or push authority;
- bypass Delegation, Validation, Envelope, approval, execution-scope, reconciliation, or failure-containment boundaries;
- acquire generic shell or generic repository-mutation authority.

User Intent Authority remains unchanged.

All authority required for a governed operation must be established through the existing governance architecture before autonomous continuation may occur.

## Phase 4 Meaning of Autonomy

Phase 4 autonomy concerns mechanical continuation after the required governed authority has already been established.

The intended distinction is:

    desired change
        -> existing governance
        -> explicit governed authority
        -> bounded mechanical continuation
        -> existing governed execution

When the governed target is Motherboard's own repository, successful completion of that same pipeline produces the self-improvement outcome.

Autonomy therefore applies to execution continuation, not to intent selection, governance, approval, or self-authorization.

## Architectural Consequence

Phase 4 must preserve the target-relative model rather than introduce a parallel self-improvement execution architecture.

Any Phase 4 implementation must attempt to reuse the existing governed execution machinery and must preserve:

- Approval != Delegation != Execution;
- explicit user-owned authority;
- exact package and envelope lineage;
- persisted execution approval;
- bounded execution scope;
- separate commit and push authority;
- fail-closed validation;
- reconciliation and provenance;
- rollback and recovery boundaries;
- immutable failed execution lineages and fresh-successor recovery;
- the prohibition on generic shell authority;
- the prohibition on independent self-authorization.

The fact that the target repository is Motherboard must not itself grant additional authority.

## Phase 4 Scope Constraint

A Phase 4 corridor must not redefine self-improvement as an independently authorized agent capability.

The Phase 4 problem is narrower:

> Allow an already-authorized governed operation to continue through the required execution machinery without manual terminal mediation, while preserving every existing authority and safety boundary.

If the operation targets Motherboard's own repository, that governed outcome is self-improvement.

If it targets another repository, it remains ordinary governed execution.

This invariant must remain true through Phase 4 closure unless contradictory repository evidence establishes that the existing architecture cannot preserve it.

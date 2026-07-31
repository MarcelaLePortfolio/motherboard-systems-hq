# Approval Request Runtime Contract

Status: Working draft — implementation not yet authorized.

## Purpose

The Approval Request runtime provides a project-scoped, read-only queue of executive decisions that are currently blocking an authoritative state transition.

It does not own Package, Preview, Preview Confirmation, or Execution Authorization lifecycles.

It derives or references pending decisions from the authoritative runtime that owns each transition.

## Candidate Runtime-Owned Requests

Verified candidates:

- Canonical Package Approval
- Preview Confirmation

Future candidate:

- Execution Authorization (when operationally enabled)

## Fundamental Contract

Every Approval Request consists of:

- Current state
- Proposed state
- Deterministic evidence
- Explicit executive question
- Authoritative decision(s)
- Owning runtime

Presentation never invents approval eligibility.

## Open Architectural Decision

The next reconciliation corridor must determine whether Approval Requests are:

- Derived from authoritative runtime state

or

- Persisted as first-class runtime objects

No implementation should begin before that decision is reconciled against the repository.

## Initial Questions

1. How is pending eligibility determined?
2. What produces deterministic request identity?
3. Which runtime owns completion?
4. How are duplicate requests prevented?
5. How is project ownership enforced?
6. What evidence references belong in the read model?
7. Which authoritative decision commands already exist?
8. How should notifications reference Approval Requests?

## Proposed Next Corridor

Inspect the Canonical Package runtime to determine whether Approval Requests should be derived or persisted.

No runtime implementation is authorized by this document.

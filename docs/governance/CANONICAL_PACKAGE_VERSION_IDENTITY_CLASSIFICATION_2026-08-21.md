# Canonical Package Version Identity Classification

Date: 2026-08-21

## Parent Phase

GOVERNANCE_RUNTIME_ACTIVATION

## Blocked Corridor

PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION

## Prerequisite

CANONICAL_PACKAGE_VERSION_IDENTITY

## Classification

AUTHORITATIVE_SEMANTICS_INSUFFICIENT_FOR_BOUNDED_IMPLEMENTATION

## Established Doctrine

- `package_id` is the immutable Package identifier.
- Delegation identity requires a distinct `package_version`.
- Package changes require a new Package version and a new Delegation.
- A Living Draft Package is updateable and non-authoritative.
- Canonical Package creation requires explicit user approval.
- Living Draft synthesis, reconciliation, and summary generation must not themselves authorize Delegation, Validation, Envelope creation, routing, assignment, or execution.

## Verified Runtime State

The live Canonical Package runtime persists:

- `package_id`
- `summary_id`
- `draft_package_id`
- `lineage_id`
- project and conversation ownership
- approved semantic fields
- approval identity and timestamp
- status and creation timestamp

It does not persist `package_version`.

The runtime also enforces one Canonical Package per `draft_package_id` through both an explicit pre-insert check and a unique index.

The Living Draft runtime separately supports mutation of a non-authoritative draft under a stable `draft_package_id`.

## Semantic Gaps

Repository evidence inspected for this classification does not establish:

1. the initial Canonical Package version value;
2. the version increment rule;
3. the authoritative event that creates a successor Canonical Package version;
4. whether a successor version retains or receives a new `package_id`;
5. how Canonical Package versions relate through lineage;
6. whether or how an earlier Canonical Package version becomes superseded;
7. the persistence and uniqueness invariants required for version identity.

These are architectural semantics, not implementation details. Selecting values or lifecycle behavior for them during implementation would invent governance behavior not established by authoritative doctrine.

## Determination

Adding a `package_version` column alone is not a sufficient or safe fix.

Production Delegation package-root reconciliation remains blocked until a minimum Canonical Package Version Identity Contract establishes the missing semantics.

No Delegation implementation, schema migration, Canonical Package lifecycle change, or production behavior change is authorized by this classification.

## Next Step

Define the minimum Canonical Package Version Identity Contract in collaboration mode before authorizing implementation.

The contract should resolve only the semantics necessary to make Canonical Package version identity authoritative and delegation-consumable, without expanding into Delegation implementation itself.

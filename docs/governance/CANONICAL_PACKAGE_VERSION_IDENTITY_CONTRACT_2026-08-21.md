# Canonical Package Version Identity Contract

Date: 2026-08-21
Parent Phase: Governance Runtime Activation
Blocked Corridor: Production Delegation Package Root Reconciliation
Prerequisite: Canonical Package Version Identity
Status: ARCHITECTURALLY_ADOPTED_PENDING_IMPLEMENTATION_AUTHORIZATION

## Purpose

Define the minimum authoritative identity and versioning contract required for immutable Canonical Package versions and safe downstream Delegation.

## Adopted Identity Model

### Living Draft

`draft_package_id` is the stable identity of the continuously evolving, non-authoritative Living Draft.

The Living Draft may continue changing during collaboration.

### Draft Revision

`draft_revision_id` identifies one immutable state of a Living Draft intentionally moved into approval review.

Each `draft_revision_id`:

- belongs to exactly one `draft_package_id`;
- belongs to exactly one `lineage_id`;
- is immutable after creation;
- may not be re-parented or reused across drafts or lineages;
- may produce at most one Canonical Package version.

Creating a Draft Revision does not itself create authoritative meaning.

### Canonical Package

`package_id` is stable across versions of the same Canonical Package lineage.

`package_version` identifies one immutable approved version.

The authoritative Canonical Package version identity is:

`(package_id, package_version)`

The first approved version is:

`package_version = 1`

Each successor version is:

`previous_package_version + 1`

Package versions are positive contiguous integers.

## Approval Boundary

A Canonical Package version may be created only through explicit operator approval of a specific `draft_revision_id`.

A changed Living Draft does not automatically create a revision.

A Draft Revision does not automatically create a Canonical Package.

A changed post-approval interpretation must become a new `draft_revision_id` and receive renewed explicit operator approval before it can become a successor Canonical Package version.

## Persistence Invariants

Each Canonical Package version must persist:

- `package_id`;
- `package_version`;
- `draft_package_id`;
- `draft_revision_id`;
- `lineage_id`;
- its approved semantic snapshot;
- approval identity and timestamp.

`(package_id, package_version)` must uniquely identify one Canonical Package version.

`draft_revision_id` must be unique across Canonical Package versions.

Multiple Canonical Package versions may share the same:

- `package_id`;
- `draft_package_id`;
- `lineage_id`.

They may not share the same `draft_revision_id`.

## Immutability and Current Version

Approved Canonical Package versions are immutable historical records.

Creating a successor version must not mutate the previous version.

No explicit `superseded` mutation state is required by this minimum contract.

The current Canonical Package version is the highest approved `package_version` for the stable `package_id`.

Earlier versions remain historically auditable.

## Delegation Boundary

Delegation authorizes one exact:

`(package_id, package_version)`

A Delegation never transfers automatically to a successor Package version.

When a successor Canonical Package version is approved:

- existing Delegations remain attached to their original Package versions;
- the successor version begins in `AWAITING_DELEGATION`;
- explicit operator Delegation is required before the successor version may enter `PENDING_GOVERNANCE_VALIDATION`.

## Preserved Authority Boundaries

AUTOMATIC_CANONICALIZATION=NO
AUTOMATIC_SUCCESSOR_VERSION_CREATION=NO
AUTOMATIC_DELEGATION=NO
DELEGATION_TRANSFER_BETWEEN_VERSIONS=NO
GOVERNANCE_VALIDATION_ACTIVATION=NO
ENVELOPE_ACTIVATION=NO
ROUTING_ACTIVATION=NO
ASSIGNMENT_ACTIVATION=NO
CADE_EXECUTION_CHANGE=NO

## Implementation Boundary

This document records the architecturally adopted minimum contract.

It does not authorize implementation.

The blocked Production Delegation Package Root Reconciliation corridor remains paused until the prerequisite runtime implementation is separately authorized, implemented, and validated.

CANONICAL_PACKAGE_VERSION_IDENTITY_CONTRACT=ARCHITECTURALLY_ADOPTED
IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE

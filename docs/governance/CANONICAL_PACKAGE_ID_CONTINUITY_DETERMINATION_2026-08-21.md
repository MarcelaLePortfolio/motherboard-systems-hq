# Canonical Package ID Continuity Determination

Date: 2026-08-21

Parent Phase: Governance Runtime Activation

Blocked Corridor: Production Delegation Package Root Reconciliation

Prerequisite: Canonical Package Version Identity

Status: EVIDENCE_DETERMINED_PENDING_ARCHITECTURAL_ADOPTION

## Question

Does existing repository evidence establish an intended Package identity model in which one `package_id` may identify multiple Package versions, with `package_version` distinguishing the specific immutable version?

## Evidence

The existing governance runtime models Package identity as the composite:

`(package_id, package_version)`

Specifically:

- `governance_packages` uses `PRIMARY KEY (package_id, package_version)`.
- `governance_delegations` references `governance_packages(package_id, package_version)` through a composite foreign key.
- Governance Validation, Envelope Gate, and Envelope artifacts each transport both `package_id` and `package_version`.
- The runtime requires `package_version` to be an integer greater than or equal to 1.
- The Canonical Delegation Specification defines `package_id` as the reference to the authorized Package.
- The Canonical Delegation Specification separately defines `package_version` as identifying the specific Package version being authorized.
- Delegation applies only to the referenced Package version.
- Repository doctrine explicitly illustrates Package v3 changing into Package v4 while the existing Delegation remains attached to v3 and v4 requires a new Delegation.
- Delegations never automatically transfer between Package versions.
- Delegation records are immutable and historically auditable.

## Determination

The final evidence check materially strengthens the stable-`package_id` model.

The repository already contains a concrete persistence and downstream lineage model in which:

`package_id` identifies the Package

and

`package_version` identifies a particular version of that Package.

The composite primary key on `(package_id, package_version)` is especially significant: it permits multiple rows sharing one `package_id` while distinguishing them by `package_version`. Downstream governance artifacts preserve the same composite identity.

Therefore:

EXISTING_GOVERNANCE_RUNTIME_PACKAGE_ID_MODEL=STABLE_ACROSS_VERSIONS

EXISTING_GOVERNANCE_RUNTIME_VERSION_IDENTITY=(package_id,package_version)

DOWNSTREAM_GOVERNANCE_COMPOSITE_IDENTITY=ESTABLISHED

This evidence provides a strong architectural basis for adopting stable `package_id` continuity for the authoritative Canonical Package lineage.

However, the current `matilda_canonical_packages` runtime does not implement this model and currently uses `package_id` alone as its primary key.

The previously recorded evidence determination also correctly established that Canonical doctrine did not independently and explicitly state whether `package_id` remains stable across versions.

Accordingly, this finding does not silently convert the legacy governance persistence model into new Canonical Package doctrine.

## Architectural Adoption Boundary

Recommended minimum contract determination:

`package_id` remains stable across versions of the same Canonical Package lineage.

`package_version` identifies each immutable approved version.

The authoritative version identity is therefore:

`(package_id, package_version)`

A changed Package must produce a successor version rather than mutate an existing approved version.

Existing Delegation remains attached to the exact earlier `(package_id, package_version)` it authorized.

A successor Package version requires a new Delegation.

This determination is evidence-backed by the existing governance runtime and consistent with the governing Delegation and lifecycle doctrine, but explicit architectural adoption remains required before implementation.

## Remaining Version Identity Decisions

Resolving Package ID continuity does not by itself authorize implementation.

The minimum Canonical Package Version Identity Contract still needs to settle:

1. initial `package_version` value;
2. exact successor increment rule;
3. Canonical persistence uniqueness constraints;
4. successor-version creation event after explicit operator approval;
5. lineage relationship representation;
6. supersession representation, if required.

## Current Boundary

PACKAGE_ID_CONTINUITY_EVIDENCE=STRONGLY_SUPPORTS_STABLE_PACKAGE_ID

PACKAGE_ID_CONTINUITY_ARCHITECTURALLY_ADOPTED=NO

CANONICAL_SCHEMA_CHANGE_AUTHORIZED=NO

CANONICAL_VERSIONING_IMPLEMENTATION_AUTHORIZED=NO

DELEGATION_REANCHOR_IMPLEMENTATION_REMAINS_PAUSED=YES

PRODUCTION_CHANGE=NONE

## Next Decision

Resolve whether the minimum Canonical Package Version Identity Contract should explicitly adopt:

INITIAL_PACKAGE_VERSION=1

and

SUCCESSOR_PACKAGE_VERSION=PREVIOUS_PACKAGE_VERSION+1

using the already-established positive-integer governance version domain.

No runtime modification is authorized by this determination.

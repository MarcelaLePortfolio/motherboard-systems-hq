# Canonical Package Legacy Provenance Migration Decision

Date: 2026-08-22
Parent Phase: Governance Runtime Activation
Blocked Corridor: Production Delegation Package Root Reconciliation
Prerequisite: Canonical Package Version Identity
Current Checkpoint: 5a4fffa5
Status: LEGACY_CANONICAL_PROVENANCE_REQUIRES_EXPLICIT_MIGRATION_SEMANTICS

## Verified Evidence

The existing approved Canonical Package:

- has package_id `pkg-ff156f5a-cd71-4cf9-8955-f3beaafb261c`;
- is status `canonical_approved`;
- was approved at `2026-08-02T16:46:05.289Z`;
- references Living Draft `matilda-draft-matilda-conversation-hq-1784855198776-kr6jjm`;
- has semantic content identical to the currently persisted source Living Draft;
- shares the same lineage as that Living Draft.

The source Living Draft was last updated at:

`2026-07-24T01:06:56.951Z`

which predates Canonical approval.

The new `matilda_draft_revisions` table does not yet exist in the live database because its schema initializer has not been invoked.

## Determination

The existing Canonical Package can safely be assigned:

`package_version = 1`

because it is the sole existing approved version of its stable `package_id`.

However, the existing Canonical Package cannot truthfully be assigned a newly generated `draft_revision_id` as though that revision existed at its historical approval boundary.

Creating a new Draft Revision now and presenting it as the historical approval candidate would manufacture provenance.

Therefore:

- legacy Canonical version 1 may be migrated to explicit version identity;
- its historical `draft_revision_id` provenance must remain absent;
- newly created Canonical Package versions must require a real immutable `draft_revision_id`;
- the absence of `draft_revision_id` is permitted only for pre-version-contract Canonical records migrated under this explicit legacy rule.

## Migration Contract

For existing legacy Canonical rows:

`package_version = 1`

`draft_revision_id = NULL`

For all Canonical versions created after activation of the version-identity runtime:

`package_version >= 2` for an existing package lineage, or `package_version = 1` for a newly created package lineage.

`draft_revision_id` must be non-null and reference an actual immutable Draft Revision used for explicit approval.

A legacy null `draft_revision_id` must never be interpreted as an approval candidate identity.

No synthetic or retrospective Draft Revision may be generated to fill historical provenance.

## Uniqueness

Canonical identity:

`UNIQUE(package_id, package_version)`

New approval provenance:

`UNIQUE(draft_revision_id)` where `draft_revision_id IS NOT NULL`

Legacy null provenance remains explicitly exceptional and historical.

## Preserved Boundaries

LEGACY_PROVENANCE_FABRICATION=NO
RETROSPECTIVE_DRAFT_REVISION_CREATION=NO
AUTOMATIC_DELEGATION=NO
DELEGATION_CHANGE=NONE
GOVERNANCE_VALIDATION_CHANGE=NONE
ENVELOPE_CHANGE=NONE
ROUTING_CHANGE=NONE
ASSIGNMENT_CHANGE=NONE
CADE_EXECUTION_CHANGE=NONE

## Implementation Boundary

This decision resolves the migration semantics necessary to implement Canonical Package version persistence without inventing historical provenance.

The next bounded implementation unit may:

- initialize Draft Revision schema during the relevant runtime startup boundary;
- migrate the existing Canonical row to `package_version = 1`;
- add nullable legacy `draft_revision_id`;
- replace draft-level Canonical uniqueness with version/revision identity constraints;
- require real `draft_revision_id` provenance for all newly approved Canonical versions.

The Production Delegation Package Root Reconciliation corridor remains paused until this prerequisite implementation is complete and validated.

LEGACY_CANONICAL_VERSION_MIGRATION=AUTHORIZED_WITH_NULL_HISTORICAL_REVISION_PROVENANCE
PRODUCTION_DELEGATION_REANCHOR=PAUSED

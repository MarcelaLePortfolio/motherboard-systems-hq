# Canonical Package Approval Candidate Identity Finding

Date: 2026-08-21
Parent Phase: Governance Runtime Activation
Blocked Corridor: Production Delegation Package Root Reconciliation
Prerequisite: Canonical Package Version Identity
Status: CLASSIFIED_PENDING_ARCHITECTURAL_DECISION

## Evidence

Repository evidence establishes that the current Living Draft runtime uses `draft_package_id` as the primary identity of a mutable, non-authoritative Living Draft Package.

The synthesis runtime receives `draft_package_id` from its caller and passes that same identity into `upsertLivingDraftPackage(...)`.

The Living Draft persistence boundary uses:

`draft_package_id TEXT PRIMARY KEY`

and the runtime performs an upsert against that identity.

Therefore repeated synthesis under the same `draft_package_id` updates the existing Living Draft rather than creating an immutable sequence of draft revisions.

The Living Draft remains explicitly non-authoritative before approval.

The current approval/read-model architecture also uses `draft_package_id` as the approval-candidate identity. Approval Request identity is derived as:

`canonical_package_approval:<draft_package_id>`

The Canonical Package runtime then records the source `draft_package_id` and currently enforces one Canonical Package per `draft_package_id`.

The repository evidence therefore establishes the current invariant:

ONE_DRAFT_PACKAGE_ID_CAN_BE_CANONICALIZED_AT_MOST_ONCE

This prevents duplicate canonicalization of the same approval candidate.

## Newly Exposed Versioning Conflict

Canonical Package versioning has now been architecturally adopted with:

INITIAL_PACKAGE_VERSION=1

SUCCESSOR_PACKAGE_VERSION=PREVIOUS_PACKAGE_VERSION+1

and prior evidence strongly supports stable Package identity across versions.

However, the current pre-approval identity model does not establish how a changed interpretation after an existing Canonical Package approval becomes a distinct approval candidate.

If the existing mutable Living Draft continues under the same `draft_package_id`, the current one-Canonical-Package-per-draft guard prevents creation of a legitimate successor Canonical Package version.

Simply removing that guard would create the opposite failure mode: the same approval candidate could potentially be canonicalized repeatedly, producing multiple Canonical Package versions without evidence that the underlying approved state changed.

Therefore Canonical Package persistence uniqueness cannot safely be selected until approval-candidate identity across revisions is defined.

## Determination

The repository supports preserving the semantic distinction between:

1. mutable pre-approval Living Draft state;
2. immutable approved Canonical Package state;
3. explicit operator approval as the authority transition;
4. one canonicalization per approval candidate;
5. successive Canonical Package versions only when changed Package meaning receives renewed explicit approval.

Repository evidence does not yet establish the identity mechanism for a successor approval candidate.

Specifically, it does not establish whether successor approval should be represented by:

- a new `draft_package_id`;
- a separate immutable draft revision identifier;
- a separate approval-candidate identifier;
- or another lineage-preserving identity mechanism.

Choosing among those mechanisms would be an architectural decision rather than implementation of an already-established runtime contract.

## Required Architectural Property

Any adopted solution must preserve all of the following:

MUTABLE_LIVING_DRAFT_BEFORE_APPROVAL=YES

EXPLICIT_OPERATOR_APPROVAL_REQUIRED=YES

ONE_CANONICALIZATION_PER_APPROVAL_CANDIDATE=YES

CHANGED_PACKAGE_REQUIRES_DISTINCT_APPROVAL_CANDIDATE=YES

SUCCESSOR_CANONICAL_VERSION_REQUIRES_RENEWED_EXPLICIT_APPROVAL=YES

PACKAGE_LINEAGE_PRESERVED=YES

DUPLICATE_CANONICALIZATION_OF_IDENTICAL_APPROVAL_CANDIDATE=PROHIBITED

AUTOMATIC_SUCCESSOR_VERSION_CREATION=PROHIBITED

## Scope Boundary

This finding does not adopt an approval-candidate identity mechanism.

It does not authorize:

- Living Draft schema changes;
- Living Draft lifecycle changes;
- Approval Request identity changes;
- Canonical Package schema changes;
- Canonical Package successor creation;
- removal of the existing duplicate-canonicalization guard;
- Delegation reanchoring;
- Governance Validation activation;
- Envelope creation;
- routing;
- assignment;
- Cade execution.

## Next Decision

Resolve the minimum successor approval-candidate identity contract.

The next architectural question is:

WHAT_IDENTITY_DISTINGUISHES_A_CHANGED_POST_APPROVAL_PACKAGE_CANDIDATE_FROM_THE_ALREADY_APPROVED_CANDIDATE_WHILE_PRESERVING_THE_SAME_PACKAGE_LINEAGE?

Implementation remains paused until that identity contract is explicitly adopted.

IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE

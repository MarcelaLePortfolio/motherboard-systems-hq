# Canonical Package Visibility — Implementation Authorization Request

## Current State

Investigation is complete.

The defect is classified as:

`MINIMAL_READ_ONLY_CANONICAL_PACKAGE_VISIBILITY_GAP`

Validated facts:

- Approval path works.
- Canonical Package creation works.
- Canonical Package persistence works.
- Exact Draft Revision canonicalization works.
- Pending approval removal works as intended.
- Current Approvals / Executive Inbox reads only pending Approval Requests.
- Approved Canonical Packages therefore lack an executive-facing post-approval presentation path.

## Proposed Implementation Boundary

Implementation is limited to:

1. project-scoped Canonical Package read model;
2. read-only Canonical Package API;
3. approved Canonical Package presentation inside the existing Approvals / Executive Inbox;
4. pending Approval Requests and approved Canonical Packages remain semantically distinct;
5. no restoration of the Packages tab.

## Protected Boundaries

No changes to:

- Canonical Package creation or persistence semantics;
- approval semantics;
- Request Changes;
- delegation;
- validation;
- envelope construction;
- execution;
- governance;
- authority.

Approval remains distinct from delegation and execution.

## Authorization Status

IMPLEMENTATION_AUTHORIZED=NO
PRODUCT_MUTATION_AUTHORIZED=NO
AUTHORITY_EXPANSION_AUTHORIZED=NO
DATABASE_SCHEMA_CHANGE_AUTHORIZED=NO
DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES

## Exact Authorization Sentence

I authorize the minimal read-only Canonical Package visibility restoration: add a project-scoped Canonical Package read model and read-only API, and present approved Canonical Packages in the existing Approvals / Executive Inbox as a state distinct from pending Approval Requests, without changing approval, Request Changes, delegation, validation, envelope, execution, governance, authority semantics, or restoring the Packages tab.

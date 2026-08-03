# Executive Approval Architecture

Status: Reconciled working draft — not yet an immutable architectural invariant.

## Purpose

The Approvals workspace is an executive authorization inbox.

It answers one question:

> What cannot proceed until the executive explicitly decides?

It is not a general notification center.

It is not merely a package browser.

It is a queue of runtime-owned decision requests.

## Core Approval Contract

Every approval request consists of:

1. Current state
2. Proposed state
3. Deterministic evidence
4. Explicit executive question
5. Executive decision

The evidence is not itself the approval.

The approval authorizes, confirms, rejects, or revises a proposed state transition according to the authoritative runtime that owns that transition.

Presentation may display an approval request, but presentation may not create approval eligibility or invent lifecycle stages.

## Verified Lifecycle

The currently reconciled lifecycle is:

Interpretation

→ Living Draft Package

→ Canonical Package Approval

→ Canonical Package

→ Assignment and Execution Eligibility

→ Dry-Run Execution Planning

→ Plan Review Ready

→ Preview

→ Explicit Preview Confirmation

→ Execution Authorization Pending

→ Execution Authorized

→ Execution

Not every transition currently requires executive authorization.

Only transitions with an authoritative approval or confirmation boundary belong in the Approvals inbox.

## Interpretation to Living Draft Package

### Current Runtime Behavior

Living Draft creation and update are automatic.

The Living Draft runtime upserts interpretation-derived package state without an executive approval gate.

### Current Classification

Not an Approvals inbox item.

Introducing an approval before Living Draft creation would be a new architectural decision and is not authorized by this draft.

## Living Draft Package to Canonical Package

### Executive Question

> Should this Reconciled Interpretation Summary become the authoritative Canonical Package?

### Verified Runtime

The Canonical Package runtime:

- requires an approval-eligible reconciled summary
- requires an explicit approval actor
- records approval timestamp
- preserves project and conversation ownership
- permits only one Canonical Package per Living Draft Package
- leaves delegation, validation, envelope, and execution authority false

### Candidate Evidence

- interpreted objective
- proposed work
- proposed artifacts
- approved scope
- constraints
- expected outcome
- source conversation
- lineage
- unresolved questions where available

### Current Classification

Verified Approvals inbox item.

## Execution Plan to Preview

### Runtime Meaning

Execution planning is deterministic, dry-run, non-mutating, and reconciliation-ready.

The resulting Execution Plan has status:

`plan_review_ready`

It includes:

- planned steps
- planned mutations
- rollback references
- ambiguity findings
- reconciliation summary

### Current Classification

The plan itself provides evidence for Preview generation.

The inspected runtime does not establish a separate executive approval command between Execution Plan and Preview generation.

Therefore, Plan Review Ready should not automatically appear as an Approvals inbox item unless a separate authoritative approval boundary is verified later.

## Preview

### Runtime Meaning

Preview is deterministic, user-visible review material generated from an approved dry-run Execution Plan.

The current Preview includes:

- preview ID
- execution plan reference
- assignment reference
- package reference
- lineage reference
- preview summary
- preview steps
- planned mutations
- rollback references
- reconciliation summary
- preview status
- creation timestamp

Preview generation does not authorize execution.

### Evidence Model

The current runtime produces structured textual evidence.

The architecture does not require Preview to remain text-only.

Future Preview evidence may include:

- rendered interface
- image
- video
- slide deck
- document
- PDF
- repository diff
- deployment preview
- other deterministic department-specific evidence

Visual or multimodal evidence remains proposed until an authoritative evidence reference, storage, and renderer contract exists.

## Preview Confirmation

### Executive Question

> Does this Preview accurately represent the intended execution?

### Verified Runtime

Preview Confirmation:

- requires an explicit confirmation actor
- records confirmation timestamp
- references the Preview
- references the Execution Plan
- references the Package
- preserves lineage
- records a confirmed result
- does not authorize execution

### Authority Meaning

Preview Confirmation verifies that the user-visible evidence accurately represents intended execution.

It establishes eligibility for a later execution-authorization decision.

It is not execution permission.

### Current Classification

Verified Approvals inbox item.

## Execution Authorization

### Executive Question

> May the system perform the represented execution?

### Verified Runtime

A distinct Execution Authorization runtime and route exist.

The authorization object references:

- Preview Confirmation
- Preview
- Execution Plan
- Package
- lineage
- authorization actor
- authorization timestamp

### Current System Boundary

The canonical execution lifecycle states that mutation-capable execution is not yet enabled.

The existing approval gate explicitly blocks:

- mutation authority
- shell execution
- autonomous execution

The inspected runtime can produce an execution-authorization-shaped object, but the current governed execution phase remains planning-only and non-mutating.

### Current Classification

Architecturally valid approval request.

Operational activation remains deferred until the mutation-capable execution corridor is explicitly enabled and reconciled.

The Approvals workspace must not imply that approval will start Cade or permit mutation while those authorities remain disabled.

## Request Changes

### Current Evidence

Governance documentation contains `REVISION_REQUESTED` semantics.

No authoritative Request Changes command was verified in the inspected Canonical Package, Preview Confirmation, or Execution Authorization runtimes.

### Current Classification

Conceptually valid but not yet runtime-authoritative.

The UI must not expose Request Changes until:

- its target transition is defined
- its persistence contract exists
- its routing behavior exists
- its effect on authoritative state is defined
- its tests are validated

## Separation of Responsibilities

### Approvals

Answers:

> What is blocked until I decide?

Owns no artifact lifecycle.

Surfaces runtime-owned decision requests.

### Packages

Answers:

> What package artifacts exist for this project?

May contain Living Draft, Canonical, and future package lineage views.

A Package may appear in Approvals while awaiting a decision and remain available in Packages as an artifact.

### Notifications

Answers:

> What should I know?

A notification may route to an approval request.

It does not own the approval, decision, evidence, or lifecycle.

### Mission Control

Answers:

> What is happening operationally?

It presents mission state and lifecycle evidence.

It does not create approval authority.

## Candidate Approvals Inbox Items

Verified for presentation planning:

1. Canonical Package Approval
2. Preview Confirmation

Architecturally recognized but not operationally enabled:

3. Execution Authorization

Not currently eligible:

- Interpretation to Living Draft
- generic Plan Review Ready
- Request Changes
- general notifications
- informational lifecycle events

## Common Presentation Contract

Each approval request should eventually expose:

- approval request ID
- approval type
- project ID
- source object ID
- current state
- proposed state
- explicit executive question
- deterministic evidence
- requesting runtime or actor
- created timestamp
- eligibility status
- available authoritative decisions
- destination after decision

The exact persisted Approval Request model has not yet been implemented.

## Remaining Runtime Gaps

Before implementing the Approvals workspace, reconcile or build:

1. A project-scoped Approval Request read model
2. Persistence or authoritative derivation rules for pending requests
3. Canonical Package approval read eligibility
4. Preview Confirmation request eligibility
5. Decision-completion behavior
6. Request Changes semantics
7. Visual and multimodal evidence references
8. Active route registration for the execution planning and preview corridor
9. Execution Authorization availability while mutation authority remains disabled
10. Notification routing into Approvals without combining the two concepts

## Next Canonical Corridor

Define the project-scoped Approval Request runtime contract.

That corridor should answer:

- Is a pending approval request persisted or derived?
- Which runtime owns each request?
- How is a request marked completed?
- How are duplicate requests prevented?
- How is project ownership enforced?
- What evidence references are included?
- Which decision actions are currently authoritative?
- How does the inbox distinguish confirmation from authorization?
- How does the UI avoid implying unavailable execution authority?

No Approvals UI implementation should begin until this runtime boundary is stable.

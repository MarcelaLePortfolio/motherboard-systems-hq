
# Preview Approval Reconciliation Finding

## Classification

Governance Reconciliation Finding

## Status

Open

## Evidence Reviewed

- docs/contracts/DELEGATION_ENVELOPE_V1.md

- docs/contracts/CANONICAL_EXECUTION_LIFECYCLE.md

- docs/contracts/CANONICAL_EXECUTION_ENVELOPE_SCHEMA.md

- docs/contracts/CANONICAL_EXECUTION_DOCTRINE_V1.md

- docs/contracts/MILESTONE_1_EXECUTION_ENVELOPE_RECONCILIATION_CHECKPOINT.md

- server/execution/execution-approval-gate.mjs

- server/execution/build-approval-artifact.mjs

- server/contracts/execution-envelope.v1.mjs

## Finding

Motherboard Systems already has a canonical governed delegation object under existing terminology:

- Delegation Envelope

- Canonical Execution Envelope

The execution envelope is the canonical governance artifact produced from Matilda-side interpretation and passed through governance validation, approval gating, Cade planning, and future execution phases.

## Existing Stabilized Architecture

The current architecture already includes:

- Matilda intent normalization

- execution envelope drafting

- governance validation

- approval artifact generation

- approval gate evaluation

- Cade dry-run planning

- reconciliation-ready output

The current lifecycle therefore does not need to be recreated from scratch.

## Narrow Gap Identified

The existing approval gate confirms the presence of an approval artifact and blocks mutation, shell execution, and autonomous execution by default.

However, current contracts and runtime fields do not explicitly require:

- user-visible preview of interpreted intent before approval

- preview artifact reference

- user confirmation that the previewed interpretation matches intent

- distinction between generic approval artifact and preview-confirmed approval artifact

## Relevant Doctrine

Canonical execution doctrine requires:

- explicit human confirmation

- explicit mutation visibility

- explicit reconciliation visibility

- fresh, session-bound, action-specific, revocable, fail-closed approval

## Prior Conflict Evidence

Earlier reconciliation identified stale wording that treated delegation itself as the approval event.

That model conflicts with later doctrine requiring explicit human confirmation.

## Reconciliation Assessment

The correct conclusion is not to create a new lifecycle from scratch.

The correct conclusion is to reconcile the existing approval gate and envelope governance with an explicit preview-confirmation boundary.

## Proposed Governance Direction

A future narrow patch should clarify that:

1. Delegation envelope construction is not sufficient user approval.

2. Governance validation is not sufficient user approval.

3. Approval artifacts should distinguish planning-only approval from preview-confirmed execution approval.

4. Preview confirmation should be represented as a user-visible confirmation boundary before mutation-capable execution.

5. Runtime implementation remains deferred unless separately authorized.

## Scope Boundary

This finding does not authorize:

- runtime mutation

- shell execution

- autonomous execution

- UI implementation

- approval panel implementation

- preview panel implementation


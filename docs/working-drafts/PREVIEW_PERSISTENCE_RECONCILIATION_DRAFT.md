# Preview Persistence Reconciliation

Status: Working draft — implementation not yet authorized.

## Current Evidence

The following runtime objects currently exist as in-memory object factories:

- Execution Plan
- Preview
- Preview Confirmation
- Execution Authorization

The inspected runtimes generate UUIDs, timestamps, and structured return values but do not persist records.

No Preview-, Confirmation-, or Execution Authorization-specific database tables were found.

## Existing Persistence Candidate

The repository already contains:

- `db/governance-lifecycle-persistence.ts`
- `db/governance-lifecycle-composition.ts`
- `governance_lifecycle_events`
- `governance_envelopes`

Existing lifecycle code consistently preserves:

- package identity
- envelope identity
- lifecycle transitions
- transition authorization evidence
- execution authorization remaining false by default

## Current Architectural Question

The next reconciliation must determine whether:

1. Execution Plan, Preview, Preview Confirmation, and Execution Authorization should become first-class persisted records.

or

2. Their authoritative state should be represented through the existing governance lifecycle and envelope persistence.

These models must not be layered together speculatively.

## Current Constraints

- Preview remains deterministic and non-mutating.
- Preview Confirmation remains distinct from Execution Authorization.
- Execution Authorization must not imply mutation, shell, or autonomous authority.
- Mutation-capable execution remains disabled.
- Approval Requests may only be derived from authoritative persisted state.
- The Approvals workspace must not surface transient objects as durable pending requests.

## Next Investigation

Inspect:

- `db/governance-lifecycle-persistence.ts`
- `db/governance-lifecycle-composition.ts`
- lifecycle event schema and transition vocabulary
- active route registration in `server/index.ts`
- whether lifecycle persistence can represent:
  - `PLAN_REVIEW_READY`
  - `PREVIEW_READY`
  - `PREVIEW_CONFIRMED`
  - `EXECUTION_AUTHORIZATION_PENDING`
  - `EXECUTION_AUTHORIZED`
- whether deterministic evidence references require separate Preview persistence

No persistence implementation is authorized by this draft.

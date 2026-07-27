# Mission Control Runtime Foundation Map

Date: 2026-07-27
Branch: feature/new-ui-shell

## Purpose

This document records the verified backend-truth boundary for Mission Control before runtime schema, API, streaming, or frontend binding work begins.

Mission Control must remain a read-only visualization layer over authoritative persisted state. It must not infer, simulate, or fabricate mission progress.

## Verified Current State

### Frontend

`client/src/shell/MissionDashboardWorkspace.tsx` currently:

- renders a static lifecycle sequence
- renders an explicit no-active-mission state
- does not claim that runtime binding exists
- remains isolated behind `WorkspaceMount`
- does not own governance or execution behavior

### Lifecycle Contracts

The repository contains explicit contracts for:

- canonical governance Packages
- Delegations
- Governance Validation Results
- Envelope Gates
- Envelopes
- Ellis assignment readiness
- the `ENVELOPE_CREATED` to `ASSIGNED` transition
- operational intake
- routing
- execution planning
- execution authorization
- lifecycle persistence

### Authoritative Transition Currently Implemented

The verified lifecycle composition supports only:

- previous state: `ENVELOPE_CREATED`
- next state: `ASSIGNED`
- transition: `ENVELOPE_CREATED_TO_ASSIGNED`

The transition remains fail-closed and does not independently authorize:

- mutation
- persistence
- scheduling
- worker claims
- execution

### Production Database Evidence

Inspection of `db/main.db` found none of the following runtime tables:

- `governance_packages`
- `governance_delegations`
- `governance_validation_results`
- `governance_envelope_gates`
- `governance_envelopes`
- `governance_lifecycle_events`
- `operational_intake_records`

Therefore, the current production database contains no authoritative governance lifecycle state that Mission Control can safely display.

## Architectural Conclusion

The lifecycle architecture exists primarily as contracts, persistence functions, composition boundaries, and tests.

The production runtime foundation is not yet established.

Mission Control UI binding must not begin until the runtime layer can provide durable, queryable evidence.

## Required Implementation Order

### Slice 1 — Runtime Schema Authority

Establish one authoritative schema-initialization path for the governance runtime tables.

Requirements:

- use `db/main.db`
- create tables idempotently
- preserve existing foreign-key relationships
- create required indexes
- avoid demo or fabricated rows
- expose no new authority
- include a focused schema test
- verify existing databases migrate safely

### Slice 2 — Persistence Validation

Verify each existing persistence function against the production schema.

Requirements:

- injected and default database paths behave consistently
- transactions fail closed
- lifecycle events and current envelope state remain consistent
- no persistence function silently creates downstream authority

### Slice 3 — Runtime Read Model

Create a read-only Mission Control projection.

The projection may expose only persisted evidence for:

- active Package identity
- Delegation
- Governance Validation
- Envelope creation
- assignment
- lifecycle events
- explicit blockers
- timestamps

Unknown or unimplemented stages must be represented as unavailable rather than inferred.

### Slice 4 — Read-Only API

Expose the projection through a project-scoped endpoint.

Requirements:

- no mutations
- no authorization side effects
- no scheduler or worker behavior
- explicit empty state
- stable identifiers and timestamps
- project isolation

### Slice 5 — Mission Control Binding

Replace static frontend stages with the authoritative projection.

The UI may visually follow the approved Mission Control target while preserving backend truth as the sole authority.

## Known Persistence Defect Requiring Verification

`db/governance-lifecycle-persistence.ts` resolves a database connection into `sqlite` but appears to call `db.prepare(...)`.

Before runtime activation, verify whether the implementation should use the resolved `sqlite` connection so the default database path cannot fail when no injected database is supplied.

This observation is not authorization to change the file without a focused test and bounded repair corridor.

## Next Corridor

The next corridor is Runtime Schema Authority discovery and implementation.

Before editing schema code, identify:

- the current production database initialization entry point
- whether governance tables already have an unused initialization function
- how existing migrations are applied
- which tests validate startup against an existing database
- the smallest safe file scope for an idempotent schema foundation

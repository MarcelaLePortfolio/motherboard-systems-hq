
# Production Lifecycle Operational Intake Readiness

Status: IMPLEMENTATION READINESS FINDING — NOT IMPLEMENTED

Date: 2026-06-29

## Purpose

Document the repository evidence showing that the Governance Lifecycle Assignment Boundary is already composed into the production lifecycle path, and that the remaining missing seam is the handoff from successful ASSIGNED lifecycle persistence into Operational Intake.

This artifact does not authorize implementation.

---

# Confirmed Implementation Lineage

Repository inspection confirms the current production lifecycle path is:

ENVELOPE_CREATED

↓

Governance Lifecycle Assignment Boundary

↓

Ellis invocation

↓

Assignment readiness result

↓

Lifecycle Transition Authorization

↓

Lifecycle Persistence

↓

ASSIGNED

This confirms the prior implementation-lineage hypothesis for the lifecycle path.

---

# Evidence

## Assignment Boundary

server/ellis/assignment-boundary.ts:

- invokes Ellis through invokeEllisFromEnvelope(...)

- requires department acknowledgement before assignment readiness is complete

- strips actor assignment from Ellis decisions

- returns assignment_ready when departmental assignment is confirmed

- does not authorize lifecycle transition, mutation, persistence, execution, actor assignment, or participation resolution

## Ellis Invocation

server/ellis/invocation.ts:

- consumes an Envelope-shaped input

- normalizes required_capabilities

- passes required_capabilities, operational_corridor, available_departments, and available_actors to Ellis decision evaluation

## Ellis Decision

server/ellis/decision.ts:

- returns assigned_department on successful assignment

- returns mutation_authorized: false

- returns execution_authorized: false

- returns persistence_authorized: false

- returns autonomous_authority: false

## Lifecycle Transition Authorization

server/ellis/lifecycle-transition-authorization.ts:

- consumes GovernanceLifecycleAssignmentBoundaryResult

- requires ENVELOPE_CREATED -> ASSIGNED

- requires assignment_boundary.ok

- requires assignment_boundary.assignment_ready

- authorizes transition without mutation or persistence

## Lifecycle Composition

db/governance-lifecycle-composition.ts:

- evaluates Governance Lifecycle Assignment Boundary

- passes the boundary result into Lifecycle Transition Authorization

- injects persistence only after successful transition authorization

- does not authorize scheduler, worker claim, endpoint, or execution behavior

## Lifecycle Persistence

db/governance-lifecycle-persistence.ts:

- requires successful transition authorization

- only supports ENVELOPE_CREATED -> ASSIGNED

- updates governance_envelopes.lifecycle_state to ASSIGNED

- does not determine assignment

- does not authorize execution

## Production Lifecycle Surface

server/lifecycle/production-lifecycle-entry-point.ts:

- invokes lifecycle composition

- exposes no scheduler, routing, orchestration, worker, execution, or new authority

server/lifecycle/production-lifecycle-consumer.ts:

- injects lifecycle persistence into the entry point

server/routes/governance-lifecycle-route.ts:

- mounts the production lifecycle consumer at /api/governance/lifecycle

- authorizes endpoint access only

- does not authorize scheduler, worker, orchestration, routing, execution, actor assignment, participation resolution, or new authority

---

# Confirmed Boundary Result

The current production lifecycle result exposes the assigned department at:

lifecycle.assignment_boundary.ellis_decision.assigned_department

Therefore the lifecycle path has enough information to supply Operational Intake with assigned_department after a successful ASSIGNED transition.

---

# Remaining Missing Seam

Operational Intake is not currently composed into the production lifecycle route.

Repository search found createOperationalIntakeRecord(...) only in:

- db/operational-intake-runtime.ts

- db/operational-intake-runtime.test.ts

No production lifecycle module currently invokes Operational Intake after lifecycle success.

The missing implementation surface is therefore:

Successful production lifecycle transition to ASSIGNED

↓

Create or return Operational Intake record

↓

Return lifecycle result with Operational Intake evidence

↓

No scheduler, routing, worker, orchestration, or execution authority

---

# Readiness Finding

The next safe implementation corridor is:

Production Lifecycle → Operational Intake Composition

The smallest safe surface appears to be additive composition after successful lifecycle persistence.

The implementation should consume:

- envelope_id

- assigned_department from lifecycle.assignment_boundary.ellis_decision.assigned_department

- existing ASSIGNED governance envelope in persistence

The implementation should not:

- determine assignment

- reinterpret governance

- mutate lifecycle beyond the already authorized transition

- authorize routing

- authorize scheduling

- authorize worker claims

- authorize orchestration

- authorize execution

- introduce autonomous Ellis behavior

---

# Open Implementation Questions

Before implementation, verify whether the Operational Intake composition should live in:

1. production lifecycle consumer

2. production lifecycle entry point

3. governance lifecycle route

4. a new authority-neutral composition wrapper around lifecycle success and Operational Intake

The likely safest option is a new authority-neutral composition wrapper, because it avoids converting lifecycle, routing, or endpoint layers into Operational Intake authority.

This remains an implementation-readiness question, not an architectural discovery question.

---

# Corridor Status

The prior implementation-lineage hypothesis is confirmed for the lifecycle path.

The remaining missing seam is narrowed to Production Lifecycle → Operational Intake Composition.

Implementation remains unauthorized until explicitly requested.


# Mission Read Model

## Status

Proposed authoritative read-model contract for the Mission Control phase.

This document defines the executive-facing Mission object that Mission Control will consume. It is an assembled, read-only view over authoritative backend artifacts.

---

# Purpose

Mission Control should never reconstruct governance state inside the client.

Instead, the backend should assemble one bounded Mission object that answers:

- What is this initiative?
- Where is it?
- Who currently owns it?
- What is it waiting for?
- Is it healthy?
- What evidence supports what I'm seeing?

This contract exists solely for observability.

It grants no mutation authority.

---

# Architectural Boundary

A Mission is currently a read model.

It is NOT:

- a new persistence artifact
- a replacement for Canonical Packages
- a replacement for Delegations
- a replacement for Validation
- a replacement for Envelopes
- a mutation command

Canonical authority remains in the underlying governance artifacts.

Mission translates that authority into executive meaning.

---

# Executive Sections

Each Mission should present information using executive concepts rather than database concepts.

## Identity

Represents:

- title
- requested outcome
- project
- canonical package identity

---

## Current Stage

Operator-facing stage.

Examples:

- Interpretation
- Awaiting Review
- Awaiting Delegation
- Governance Validation
- Envelope Created
- Assigned
- Operational Intake
- Department Active
- Executive Review
- Completed
- Blocked
- Unknown

Stage is derived only from authoritative backend state.

---

## Current Owner

Represents organizational responsibility.

Possible owners:

- CEO
- Matilda
- Governance
- Department
- Executive Review
- Unknown

Ownership must never be inferred by the client.

---

## Awaiting

Explains why progress has paused.

Examples:

- CEO Review
- Delegation Authorization
- Governance Validation
- Department Intake
- Executive Review
- Clarification
- Dependency
- None
- Unknown

---

## Mission Health

Mission health is operational.

It is NOT infrastructure health.

Possible values:

- Healthy
- Waiting
- Needs Attention
- Blocked
- Escalated
- Deviation
- Completed
- Unknown

---

## Executive Attention

Mission Control should identify when CEO attention is required.

Mission Control may link to the future Delegation workspace.

Mission Control should not perform the decision itself.

---

## Timeline

Ordered authoritative milestones.

Each event must identify:

- event type
- timestamp
- originating artifact
- summary

Timeline summaries may simplify language.

They must never change meaning.

---

## Evidence

Mission Control should communicate whether displayed conclusions are supported by authoritative evidence.

Missing lineage must remain visible rather than hidden.

---

# Initial Mission Shape

Mission

├── Identity

├── Current Stage

├── Current Owner

├── Awaiting

├── Mission Health

├── Executive Attention

├── Timeline

├── Evidence

└── Artifact References

---

# Initial Source Artifacts

The first Mission assembler should derive only from authoritative governance persistence:

- governance_packages
- governance_delegations
- governance_validation_results
- governance_envelope_gates
- governance_envelopes
- governance_lifecycle_events

No execution, department activity, or outcome completion should be inferred until authoritative persistence exists.

---

# Design Rules

Mission Control consumes this object.

Mission Control does not assemble it.

Mission Control does not mutate it.

Mission Control does not advance lifecycle.

Mission Control does not infer authority.

Mission Control observes.

---

# Next Corridor

Before implementing the Mission assembler, inspect:

- current governance status values
- authorization values
- validation values
- lifecycle values
- project linkage
- assignment linkage
- artifact lineage

The assembler should be built from repository evidence rather than assumptions.


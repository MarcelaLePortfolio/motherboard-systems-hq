
# Engineering Doctrine – Inspection Depth Rule

Date: 2026-07-04

## Purpose

Establish a permanent engineering doctrine governing repository inspection during implementation corridors.

## Principle

Repository inspection is a means to reduce implementation uncertainty, not an objective in itself.

Inspection should proceed only until the active implementation surface has been identified and the implementation path has stabilized.

Once that boundary has been established, inspection should stop.

The next activity should be one of:

- make the architectural decision,

- begin implementation,

- validate implementation,

- or intentionally defer the corridor.

## Inspection Proportionality

Repository inspection should always be proportional to the uncertainty being resolved.

Prefer:

- targeted inspection of known implementation surfaces,

- narrow searches,

- bounded output,

- evidence directly related to the active milestone.

Avoid:

- broad repository scans,

- repeated inspection of previously validated areas,

- exploration that does not materially reduce uncertainty,

- reopening settled implementation surfaces without new evidence.

## Attention Budget

Constituent attention is an engineering resource.

Every inspection command should answer the question:

"What implementation uncertainty does this reduce?"

If the answer is "none," the inspection should not be performed.

## Relationship to Existing Doctrine

This doctrine reinforces:

- Evidence-first discipline.

- Scope-first discipline.

- Anti-speculation.

- Attention Budget.

- Collaboration by default.

It introduces the principle of **Inspection Proportionality**, ensuring repository exploration remains aligned with the active implementation milestone rather than maximizing discovery.

## Adoption

This doctrine should be incorporated into the canonical Immutable Operating Doctrine during the next handoff regeneration.


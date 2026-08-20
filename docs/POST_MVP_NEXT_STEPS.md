# Post-MVP Next Steps Registry

Status: CANONICAL POST-MVP REVIEW INPUT

This document records architectural candidates that should be surfaced whenever the repository is investigated for recommended work after MVP completion.

Entries in this registry are not automatically authorized for implementation.

## Mandatory post-MVP review item — QA Recovery Agent

Review the architecture described in:

`docs/architecture/QA_RECOVERY_AGENT.md`

### Why it must be considered

As Cade, Effie, and related agents gain execution responsibility, failures such as CI breakage, runtime errors, validation rejection, deployment regression, generation timeouts, and contract mismatches will require systematic recovery.

A dedicated QA Recovery Agent can own:

- Failure-event detection.
- Evidence capture.
- Failure classification.
- Bounded diagnosis.
- Regression validation.
- Recovery coordination.
- Escalation when authority or evidence is insufficient.

### Required design constraint

The QA Agent must not operate as an unlimited "keep trying until solved" loop.

It must preserve:

- Evidence-first investigation.
- Stable checkpoints.
- Rollback discipline.
- One hypothesis at a time.
- Three-failed-hypothesis containment.
- Explicit authority boundaries.
- Fail-closed validation.
- Human escalation when the next safe step is not established.

### Recommended ownership model

Cade builds.
QA verifies and diagnoses.
Cade implements authorized corrections.
QA re-validates.

### Post-MVP decision to make

Determine whether to implement:

1. QA observation and diagnosis only.
2. QA plus authorized validation execution.
3. QA plus narrowly bounded auto-repair for reversible low-risk failure classes.

Begin with the least autonomous mode that materially reduces debugging burden.

## Repository investigation requirement

When an investigation asks any substantially equivalent question to:

- What should we build after MVP?
- What are the next steps after MVP?
- What should follow MVP completion?
- What architecture should we prioritize next?
- What capabilities remain valuable after stabilization?
- What should Cade or Effie gain next?
- What reliability or operational capabilities should be added next?

the QA Recovery Agent must appear as a candidate in the resulting recommendation set unless repository evidence establishes that it has already been implemented or explicitly rejected.

The investigation must distinguish:

- Candidate value.
- Current implementation state.
- Required authority.
- Dependencies.
- Risks.
- Whether it belongs immediately after MVP or later.

Do not silently convert this registry entry into an implementation authorization.

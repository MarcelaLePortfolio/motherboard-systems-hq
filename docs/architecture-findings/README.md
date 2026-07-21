# Architecture Findings

## Purpose

Architecture Findings (AFs) capture durable architectural knowledge that has been established through repository evidence, runtime observation, or accepted architectural decisions.

They are intended to answer questions that future contributors should not need to rediscover through repository archaeology.

Architecture Findings are distinct from:

- Checkpoints (point-in-time project state)
- Plans (future work)
- Notes (working thoughts)
- Reconciliation documents (decision resolution)

## Lifecycle

Proposed → Accepted → Superseded

Accepted findings should change only if new evidence invalidates them.

Superseded findings should never be deleted. They should instead reference the finding that replaced them.

## Standard Template

Each finding should include:

- Status
- Confidence
- Question
- Evidence
- Finding
- Implications
- Supersedes (if applicable)

## Evidence Standard

Every accepted finding should be traceable to repository inspection, runtime observation, implementation evidence, or an accepted architectural decision.

The evidence should be stronger than speculation.

## Numbering

AF-001
AF-002
AF-003
...

## What Should Become an Architecture Finding

An Architecture Finding should document knowledge that is expected to remain useful across multiple implementation corridors.

Typical candidates include:

- architectural boundaries
- authority ownership
- runtime ownership
- API contracts
- migration constraints
- serving architecture
- repository structure
- accepted architectural decisions supported by evidence

The following generally do **not** belong as Architecture Findings:

- temporary implementation details
- debugging sessions
- one-time fixes
- planning discussions
- hypotheses that have not been validated
- point-in-time project status

When in doubt, ask:

> "Would a future contributor benefit from knowing this without having to rediscover it?"

If the answer is yes, it is likely an Architecture Finding.

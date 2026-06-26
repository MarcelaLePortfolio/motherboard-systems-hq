
# Production Runtime Integration Planning

## Finding

Repository inspection does not show a production runtime surface that currently calls `createGovernanceEnvelope(...)`.

The only direct calls found are:

- `db/governance-runtime.ts`

- `scripts/smoke-governance-envelope-runtime.mjs`

- historical evidence / assessment documents

A prior assessment also records:

> No `createGovernanceEnvelope(...)` runtime surface was found in `src`, `server`, `app`, or `lib`.

## Planning Conclusion

There is no existing production envelope creation path available as the canonical insertion point.

Therefore, the next planning question is not where to place the lifecycle integration caller after an existing production envelope creation flow.

The next planning question is:

> What is the smallest production runtime surface that should become responsible for invoking the already-authorized governance lifecycle corridor?

## Scope Boundary

This does not authorize implementation.

This does not authorize:

- schema modification

- Envelope contract expansion

- endpoint creation

- scheduler integration

- worker integration

- orchestration integration

- assignment persistence expansion

- autonomous Ellis runtime

- new architectural authority

## Current Best Candidate

The smallest safe production integration surface is a thin production caller that consumes an already-created Governance Envelope and invokes the completed lifecycle integration caller.

This caller should remain:

- explicit

- synchronous

- deterministic

- orchestration-free

- scheduler-free

- worker-free

- execution-free

- endpoint-free unless separately authorized

## Authority Boundary

The active authority boundary is Lifecycle Authority consuming an Envelope and producing an authorized lifecycle transition through existing boundaries.

It must not become:

- Database Authority

- Persistence Authority beyond the existing lifecycle persistence boundary

- Assignment Authority beyond the existing non-mutating assignment boundary

- Execution Authority

- Orchestration Authority

- Runtime Caller Authority

## Next Canonical Question

Before implementation, determine whether the production integration surface should be:

1. a shared server-side lifecycle service, or

2. a narrow production caller adjacent to the future canonical envelope creation path.

At present, repository evidence does not justify wiring into scheduler, worker, or orchestration systems.


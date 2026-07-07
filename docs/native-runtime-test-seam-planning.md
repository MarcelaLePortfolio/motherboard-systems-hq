import Database from "better-sqlite3";

# Native Runtime Test Seam Planning

## Finding

The native database dependency enters the lifecycle flow at module-load time.

`db/governance-lifecycle-integration.ts` imports:

- `better-sqlite3`

- `persistGovernanceEnvelopeLifecycleTransition(...)`

`db/governance-lifecycle-persistence.ts` creates a default native database connection at module load:

    const defaultSqlite = new Database("db/main.db");

    defaultSqlite.pragma("foreign_keys = ON");

Therefore any architectural unit test that imports the full lifecycle integration caller also imports the native database binding.

## Seam Location

The smallest architectural seam is between:

1. lifecycle assignment and transition authorization

2. native lifecycle persistence

The seam should preserve:

- Assignment Boundary

- Lifecycle Transition Authorization Boundary

- Governance Lifecycle Persistence Boundary

The seam should not merge those boundaries.

## Recommended Shape

Introduce a persistence-injected lifecycle composition path.

The architectural composition should be testable without importing `governance-lifecycle-persistence.ts`.

The native production composition should continue to use the existing persistence boundary.

Conceptually:

    Architectural Lifecycle Composition

      Assignment Boundary

      Transition Authorization Boundary

      injected persistence function

    Native Lifecycle Integration

      Architectural Lifecycle Composition

      existing Governance Lifecycle Persistence Boundary

## Authority Preservation

The seam must not introduce:

- new Lifecycle Mutation Authority

- Runtime Caller Authority

- Database Authority expansion

- Assignment Authority expansion

- Execution Authority

- Scheduler Authority

- Worker Authority

- Orchestration Authority

## Implementation Implication

A future implementation should avoid making architectural tests import a module that constructs a default native database connection at load time.

The implementation should either:

1. extract lifecycle composition into a native-free module, or

2. allow the integration caller to receive a persistence function without importing the native persistence module in test paths.

## Validation Implication

Architectural tests should validate:

- assignment boundary rejection

- transition authorization rejection

- successful composition with injected fake persistence

- failed-closed behavior

- no endpoint authorization

- no scheduler authorization

- no worker authorization

- no routing authorization

- no execution authorization

Native persistence tests should remain separate.

## Scope Boundary

This planning does not authorize implementation.

It does not authorize:

- dependency policy changes

- `pnpm-workspace.yaml` changes

- endpoint creation

- scheduler integration

- worker integration

- orchestration integration

- schema changes

- execution behavior

- lifecycle authority expansion

## Next Canonical Milestone

Implementation readiness assessment for the native runtime test seam.


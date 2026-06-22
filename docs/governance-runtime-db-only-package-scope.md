
# Governance Runtime DB-Only Package Scope

Status: PLANNING ONLY

Baseline: 3b8028a8

## Decision

Continue governance runtime planning without touching:

- scripts/_local/agent-runtime/launch-matilda.mjs

## Scope

The next runtime step is DB-only Package creation planning.

## In scope

- db/client.ts usage pattern

- governance_packages insert behavior

- duplicate package_id + package_version rejection

- required input validation

- returning Package identity after insert

## Out of scope

- launch-matilda.mjs recovery

- TypeScript recovery corridor

- API routes

- UI surfaces

- Delegation creation

- Governance Validation execution

- Envelope Gate evaluation

- Envelope creation

- routing

- assignment

- execution

## Current repo finding

The governance lifecycle tables exist in:

- db/governance.schema.ts

- drizzle/0004_governance_lifecycle_artifacts.sql

No dedicated governance runtime surface exists yet.

## Next question

What is the smallest safe internal Package creation function?


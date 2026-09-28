# Phase 4 — Live Authority / Provenance Bridge Contract

## Status

- Stable baseline at determination: `fb3e70861`
- Authority model: resolved
- Live bridge implementation: authorized but not yet completed at this checkpoint
- This document records the architectural determination independently of the implementation.

## Architectural Determination

The live governed-execution bridge must preserve a strict distinction between **authority** and **provenance**.

### Authority-Bearing Records

The existing governance execution system remains the sole source of execution authority:

- `governance_execution_approvals`
- `governance_execution_scopes`

The existing authoritative governance approval and scope loaders must be reused.

Governance execution scope binds its authority to the corresponding governance approval and package identity. The live bridge must not reconstruct or replace that authority through a parallel mechanism.

### Provenance-Only Records

The Matilda execution lifecycle supplies provenance evidence:

- durable execution plan
- durable preview
- durable preview confirmation
- canonical package/version/lineage identity

These records establish that the artifact presented for governed execution is the same artifact that progressed through the durable Matilda planning and confirmation lifecycle.

They do not independently grant governance execution authority.

In particular:

- Preview confirmation is not governance approval.
- Preview confirmation must not create governance execution scope.
- Preview confirmation must not independently authorize execution.
- Successful provenance validation must not be interpreted as new authority.

## Required Live Bridge

The smallest compliant bridge must:

1. Consume the existing authoritative governance execution approval.
2. Consume the existing authoritative governance execution scope.
3. Require exact agreement on `package_id` and `package_version` across the authority-bearing records and governed execution context.
4. Resolve the exact canonical Matilda package version and its `lineage_id`.
5. Load the durable Matilda execution plan using the existing loader.
6. Load the durable Matilda preview using the existing loader.
7. Load the durable Matilda preview confirmation using the existing loader.
8. Require the entire Matilda provenance chain to bind to the exact canonical package/version/lineage.
9. Apply the existing execution-authority core only after the required provenance has been established.
10. Treat execution-authority evaluation as a provenance prerequisite rather than a replacement for governance approval or scope.
11. Invoke only the existing governed execution boundary using the existing authoritative governance approval/scope identity.

## Required Identity Invariants

The bridge must require exact identity agreement for:

- `package_id`
- `package_version`
- canonical `lineage_id`
- execution-plan provenance
- preview provenance
- preview-confirmation provenance
- governance approval identity
- governance scope identity

Missing, ambiguous, stale, or mismatched evidence must fail closed.

## Existing Components to Reuse

The implementation should reuse, rather than reproduce, the existing contracts for:

- `loadGovernanceExecutionApproval`
- `loadGovernanceExecutionScope`
- canonical package/version resolution
- Matilda execution-plan loading
- Matilda preview loading
- Matilda preview-confirmation loading
- execution-authority evaluation
- governed execution invocation

## Prohibited Approaches

The following approaches are explicitly outside the architecture:

- Direct SQL reconstruction of governance authority inside the live handoff
- A second or alternate execution approval system
- Promotion of preview confirmation into governance approval
- Inferring governance authority from successful provenance validation
- Bypassing `governance_execution_approvals`
- Bypassing `governance_execution_scopes`
- Connecting an alternate or legacy authority path
- Introducing new authority as part of the bridge

## Investigation History

An earlier bridge approach attempted to reconstruct authority/provenance relationships directly through SQL inside the governed-execution handoff.

That approach was reverted to stable baseline and is closed.

The subsequent investigation established that the existing governance approval and scope loaders provide the authority-bearing contracts needed by the bridge. The remaining implementation should therefore compose those existing contracts with the durable Matilda provenance loaders instead of recreating authority resolution.

## Implementation Boundary

Authorized implementation scope is limited to:

- the minimum live handoff/composition surfaces required for the bridge; and
- directly necessary focused tests.

The implementation must preserve all existing governance and execution authority boundaries.

## Governing Principle

**Matilda proves provenance; governance grants authority.**

The live bridge may prove that existing governance authority applies to the exact durable Matilda artifact being executed.

It may never create that authority itself.

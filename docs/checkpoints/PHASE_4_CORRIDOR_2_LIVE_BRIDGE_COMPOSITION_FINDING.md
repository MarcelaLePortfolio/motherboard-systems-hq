# Phase 4 Corridor 2 — Live Bridge Composition Finding

## Status

Investigation complete for the existing governed-execution handoff composition seam.

Baseline:

- Branch: `feature/support-source-references-runtime`
- HEAD: `883ed4575`
- Remote HEAD: `883ed4575`
- Divergence: `0 0`
- Authorized bridge surfaces clean: YES

## Verified Existing Production Path

The terminal scheduler/runtime composition reaches:

`production-scheduler-runtime-terminal-governed-execution-composition.ts`

which conditionally invokes:

`handoffSchedulerReadinessToGovernedExecution(...)`

in:

`server/operational/governed-execution-handoff.ts`

The governed execution handoff then invokes the existing:

`handleGovernanceExecutionRouteRequest(...)`

from:

`server/routes/governance-execution-route.ts`

Therefore the existing live composition path is:

Scheduler/runtime terminal readiness
→ governed execution handoff
→ governance execution route
→ existing governed execution machinery.

No alternate execution route is required.

## Verified Authority Boundary

The governance execution route is the existing authority composition point.

It carries and validates:

- `approval_id`
- `envelope_id`
- `package_id`
- `package_version`

The authority source remains the existing persisted governance approval and execution scope.

The governed-execution handoff transports effect intent but does not itself confer:

- scheduler authority
- routing authority
- worker-claim authority
- orchestration authority
- execution authority
- commit authority
- push authority
- new authority

The existing fail-closed boundary remains authoritative.

## Important Reconciliation Finding

The current governed-execution handoff contains a local helper:

`resolveApprovalIdentityForEnvelope(...)`

That helper directly queries `governance_execution_scopes` to reconstruct:

- `approval_id`
- `envelope_id`
- `package_id`
- `package_version`

This is redundant with the already-existing governance execution authority-loading path.

Accordingly, the next implementation must not add another authority source or expand this direct SQL reconstruction.

The bounded implementation target is to remove or replace redundant authority reconstruction at the handoff seam by consuming the existing persisted governance authority contract through its established loader/composition boundary.

## Matilda Provenance Boundary

Matilda execution planning already preserves non-authoritative provenance.

The execution-plan runtime records:

- `execution_plan_id`
- `assignment_id`
- `package_id`
- `lineage_id`
- assigned agent
- plan status

Its contract explicitly records:

- `preview_generated: false`
- `preview_confirmed: false`
- `execution_authorized: false`

The execution plan therefore does not constitute execution authority.

For Corridor 2:

`MATILDA_ROLE=PROVENANCE_VALIDATION_ONLY`

Matilda provenance may be used to prove that the operational lineage corresponds to the already-governed package lineage.

It must not:

- create an approval
- create an execution scope
- synthesize authority
- replace persisted governance approval
- replace persisted governance scope
- independently authorize commit or push

## Implementation Target

The minimum compliant bridge is:

1. Preserve scheduler/runtime readiness as non-authoritative operational evidence.
2. Preserve explicit effect intent as intent transport only.
3. Resolve execution authority exclusively through the existing persisted governance approval/scope machinery.
4. Validate Matilda provenance against the already-authoritative package lineage.
5. Fail closed on missing, ambiguous, or mismatched provenance.
6. Invoke the existing governance execution route without introducing an alternate authority path.

Required invariant:

`Approval ≠ Delegation ≠ Execution`

Additional invariants:

`AUTHORITY_SOURCE=EXISTING_PERSISTED_GOVERNANCE_APPROVAL_AND_SCOPE`

`MATILDA_ROLE=PROVENANCE_VALIDATION_ONLY`

`DIRECT_SQL_AUTHORITY_RECONSTRUCTION=PROHIBITED_AS_NEW_AUTHORITY_PATH`

`ALTERNATE_AUTHORITY_PATH=PROHIBITED`

`NEW_AUTHORITY_INTRODUCED=NO`

## Scope Determination

Corridor 2 does not require a new execution mechanism.

The remaining implementation problem is narrower:

bind Matilda provenance validation into the existing live governed-execution composition while eliminating redundant authority reconstruction at the handoff seam and preserving the governance execution route as the sole production authority boundary.

No implementation of that runtime change is included in this checkpoint.

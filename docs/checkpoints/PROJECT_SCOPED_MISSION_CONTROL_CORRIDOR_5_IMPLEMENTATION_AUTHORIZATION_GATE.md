# Project-Scoped Mission Control & Active Mission Binding — Corridor 5 Implementation Authorization Gate

Milestone: Executive Mission Control
Phase: Project-Scoped Mission Control & Active Mission Binding
Corridor: Project Isolation Boundary
Protected implementation-unit commit: 1180dea4
Protected DR commit: f3b46533
Full DR checkpoint: 20260820_221628
Gate status: AWAITING_EXPLICIT_OPERATOR_AUTHORIZATION
Implementation authorized: NO

## Exact Unit Awaiting Authorization

MINIMUM_IMPLEMENTATION_UNIT=PROVIDER_PROJECT_BINDING_RESET_AND_RESULT_REJECTION

The only implementation eligible for authorization is:

1. Bind `MissionControlProvider` to authoritative active project identity and clear project-dependent Mission Control state when that identity changes.

2. Fail closed when a successful Mission Read result has an authoritative `identity.project_id` that does not match the active project.

## Authorized-Scope Ceiling

If explicitly authorized, the implementation may:

- pass active project identity into `MissionControlProvider`;
- invalidate stale in-flight Mission Control reads after project changes;
- clear `mission`, `lastPackageId`, and provider error/status state on project changes;
- reject cross-project Mission Read results;
- preserve read-only Mission Control behavior.

It must not:

- modify Mission Read backend lookup semantics;
- add active mission discovery;
- replace or reinterpret `ACTIVE_PACKAGE_ID`;
- select Packages by recency or approval state;
- derive Package identity from project identity;
- mount governance routes;
- mutate governance lifecycle state;
- resume Production Lifecycle Entry Point work;
- weaken any fail-closed behavior.

## Rollback Boundary

ROLLBACK_DR=20260820_221628
IMPLEMENTATION_UNIT_COMMIT=1180dea4
PROTECTED_SCOPE_COMMIT=f3b46533

Any implementation exceeding this scope must stop and be separately classified before modification.

## Gate

IMPLEMENTATION_AUTHORIZED=NO
AWAITING_EXPLICIT_OPERATOR_AUTHORIZATION=YES
PRODUCTION_CHANGE=NONE

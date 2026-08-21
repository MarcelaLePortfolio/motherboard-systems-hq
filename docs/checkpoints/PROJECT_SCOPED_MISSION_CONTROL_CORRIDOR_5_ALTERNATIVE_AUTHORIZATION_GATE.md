# Project-Scoped Mission Control & Active Mission Binding — Corridor 5 Alternative Authorization Gate

Milestone: Executive Mission Control
Phase: Project-Scoped Mission Control & Active Mission Binding
Corridor: Project Isolation Boundary
Protected classification commit: 7d4bc3de
Protected DR commit: 2e8d5a54
Stable runtime base: c828acb8
Status: AUTHORIZATION_REQUIRED

## Proposed Implementation Unit

MISSION_READ_CLIENT_EXPECTED_PROJECT_VALIDATION

## Authorized Scope If Approved

If explicitly authorized, implementation may only:

- allow the Mission Read client invocation to receive the expected active project identity;
- compare returned `mission.identity.project_id` with that expected identity;
- fail closed before returning a mismatched Mission Read model;
- obtain active project identity from existing project context at the dashboard invocation boundary.

## Prohibited Scope

The implementation must not:

- add MissionControlProvider reset effects;
- remount MissionControlProvider for project changes;
- alter MissionControlProvider lifecycle behavior;
- replace or infer `ACTIVE_PACKAGE_ID`;
- implement active Package selection;
- change Mission Read backend routes;
- change Mission Read repository queries;
- change governance persistence or lifecycle state;
- change Atlas;
- weaken Mission Control read-only behavior.

## Mandatory Validation

FULL_MISSION_CONTROL_UI_RENDERING=REQUIRED
PREPARING_STATE_REGRESSION=PROHIBITED
MATCHING_PROJECT_MISSION_READ=REQUIRED_PASS
MISMATCHED_PROJECT_MISSION_READ=REQUIRED_FAIL_CLOSED
MISSION_CONTROL_PROVIDER_LIFECYCLE_UNCHANGED=REQUIRED
ACTIVE_PACKAGE_ID_UNCHANGED=REQUIRED
MISSION_READ_BACKEND_UNCHANGED=REQUIRED
MISSION_READ_REPOSITORY_UNCHANGED=REQUIRED
GOVERNANCE_LIFECYCLE_MUTATION=PROHIBITED

## Gate

IMPLEMENTATION_AUTHORIZED=NO
IMPLEMENTATION_STARTED=NO
PRODUCTION_CHANGE=NONE

Explicit user authorization is required before implementing:

MISSION_READ_CLIENT_EXPECTED_PROJECT_VALIDATION

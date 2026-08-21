# Project-Scoped Mission Control & Active Mission Binding — Corridor 5 Implementation Unit

Milestone: Executive Mission Control
Phase: Project-Scoped Mission Control & Active Mission Binding
Corridor: Project Isolation Boundary
Status: ACTIVE
Mode: Collaboration / Implementation Classification
Implementation authorized: NO

## Minimum Safe Implementation Unit

The smallest evidence-supported implementation unit is:

PROVIDER_PROJECT_BINDING_RESET_AND_RESULT_REJECTION

This unit consists of two coordinated protections:

1. Bind `MissionControlProvider` to the active project identity and clear project-dependent Mission Control state whenever that identity changes.

2. Fail closed when a loaded Mission Read result has an authoritative `mission.identity.project_id` that does not match the active project.

## Evidence

- `WorkspaceMount` already derives `activeProjectId`.
- `MissionControlProvider` currently receives no active project identity.
- `MissionControlProvider` retains `mission` and `lastPackageId`.
- No provider-level project-change reset exists.
- Mission Read already returns authoritative `project_id`.
- No Mission Control project-id mismatch rejection exists.
- `PackageReadProvider` demonstrates an existing repository-consistent project-scoped provider pattern.
- Neither provider binding nor mismatch rejection requires active Package discovery.
- The backend Mission Read contract does not need to change for this bounded unit.

## Implementation Boundary

An explicitly authorized implementation may:

- pass active project identity into `MissionControlProvider`;
- expose active project identity through the Mission Control context if required by the provider contract;
- invalidate outstanding Mission Control requests when the project changes;
- clear `mission`;
- clear `lastPackageId`;
- clear prior Mission Control error state;
- return Mission Control to an idle/no-current-mission state on project change;
- reject a successful Mission Read result when its non-matching authoritative `project_id` belongs to another project;
- fail closed rather than displaying cross-project mission state.

An explicitly authorized implementation must not:

- change Mission Read repository lookup semantics;
- add projectId to the Mission Read backend contract;
- discover an active Package;
- replace `ACTIVE_PACKAGE_ID`;
- choose a Package by recency or approval state;
- derive Package identity from active project identity;
- create or mutate governance lifecycle artifacts;
- mount downstream governance routes;
- repair or resume Production Lifecycle Entry Point implementation;
- infer downstream operational mission state.

## Important Scope Note

The existing hard-coded `ACTIVE_PACKAGE_ID` remains a separately blocked active-mission-selection concern.

Corridor 5 project isolation may protect against cross-project contamination around that existing behavior, but it must not treat that hard-coded Package identity as authoritative or attempt to replace it with inferred active-mission logic.

## Disposition

MINIMUM_IMPLEMENTATION_UNIT=PROVIDER_PROJECT_BINDING_RESET_AND_RESULT_REJECTION
PROVIDER_PROJECT_BINDING_REQUIRED=YES
PROJECT_CHANGE_STATE_RESET_REQUIRED=YES
PROJECT_MISMATCH_FAIL_CLOSED_REQUIRED=YES
BACKEND_MISSION_READ_CONTRACT_CHANGE_REQUIRED=NO
MISSION_READ_REPOSITORY_CHANGE_REQUIRED=NO
ACTIVE_PACKAGE_SELECTION_REQUIRED=NO
ACTIVE_PACKAGE_SELECTION_AUTHORIZED=NO
HARDCODED_ACTIVE_PACKAGE_REPLACEMENT_IN_SCOPE=NO
MISSION_CONTROL_READ_ONLY_PRESERVED=YES
UPSTREAM_GOVERNANCE_RUNTIME_DEPENDENCY_REMAINS=YES
IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE

## Next Action

Protect this implementation-unit classification with DR.

Only after that checkpoint may explicit implementation authorization be considered for this exact bounded unit.

# Project-Scoped Mission Control & Active Mission Binding — Corridor 5 Alternative Approach

Milestone: Executive Mission Control
Phase: Project-Scoped Mission Control & Active Mission Binding
Corridor: Project Isolation Boundary
Stable runtime base: c828acb8
Revert commit: 93dbb947
Live UI restored commit: f99377b5
Alternative-classification commit: 40caff46
Status: ALTERNATIVE_APPROACH_CLASSIFIED
Implementation authorized: NO

## Failed Approach

The first Corridor 5 implementation bound active project identity directly into `MissionControlProvider` and used provider project-change reset behavior together with result mismatch rejection.

That implementation regressed the live Mission Control workspace to a persistent `Preparing Mission Control…` state.

The implementation was reverted and the full Mission Control UI was restored.

This approach must not be repeated.

FAILED_IMPLEMENTATION=1e2c8343
FAILED_APPROACH=PROVIDER_PROJECT_BINDING_RESET_AND_RESULT_REJECTION_AS_IMPLEMENTED
FAILED_APPROACH_REVERTED=YES

## Alternative Determination

A materially different project-isolation boundary is available at the Mission Read client invocation surface.

The active project identity already exists in client project context.

The Mission Read response already contains authoritative:

`mission.identity.project_id`

Therefore project isolation can be enforced before a Mission Read model is accepted into Mission Control state by supplying the expected active project identity to the client-side Mission Read invocation and failing closed when the returned authoritative project identity does not match.

This approach does not require:

- provider project-change reset effects;
- provider remounting;
- backend Mission Read changes;
- repository lookup changes;
- active Package discovery;
- replacement of `ACTIVE_PACKAGE_ID`;
- downstream governance activation.

## Minimum Alternative Implementation Unit

MISSION_READ_CLIENT_EXPECTED_PROJECT_VALIDATION

The smallest candidate unit is:

1. Allow the Mission Read client invocation to receive an expected project identity.

2. After a successful Mission Read response, compare `mission.identity.project_id` to that expected project identity.

3. Fail closed before returning the Mission Read model when the identities do not match.

4. Supply the active project identity from the existing project context at the Mission Control dashboard invocation boundary.

## Why This Is Materially Different

The failed implementation changed provider lifecycle behavior.

This alternative does not.

It preserves the existing stable `MissionControlProvider` lifecycle and state behavior.

Project isolation occurs at data acceptance rather than provider reset/remount behavior.

The existing full Mission Control rendering path therefore remains structurally unchanged except for the project-aware Mission Read invocation.

## Preserved Boundaries

PROVIDER_RESET_EFFECT_REQUIRED=NO
PROVIDER_REMOUNT_REQUIRED=NO
MISSION_CONTROL_PROVIDER_LIFECYCLE_CHANGE_REQUIRED=NO
MISSION_READ_CLIENT_CHANGE_REQUIRED=YES
MISSION_READ_BACKEND_CHANGE_REQUIRED=NO
MISSION_READ_REPOSITORY_CHANGE_REQUIRED=NO
ACTIVE_PROJECT_CONTEXT_ALREADY_AVAILABLE=YES
AUTHORITATIVE_PROJECT_ID_ALREADY_RETURNED=YES
ACTIVE_PACKAGE_SELECTION_REQUIRED=NO
ACTIVE_PACKAGE_SELECTION_AUTHORIZED=NO
ACTIVE_PACKAGE_ID_REPLACEMENT_IN_SCOPE=NO
GOVERNANCE_RUNTIME_CHANGE_REQUIRED=NO
ATLAS_CHANGE_REQUIRED=NO
MISSION_CONTROL_READ_ONLY_PRESERVED=YES
IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE

## Mandatory Validation

Any future explicitly authorized implementation must validate all of the following:

- the full Mission Control dashboard still renders;
- the workspace does not remain stuck at `Preparing Mission Control…`;
- a matching-project Mission Read continues to render normally;
- a mismatched-project Mission Read fails closed;
- `MissionControlProvider` lifecycle behavior remains unchanged;
- `ACTIVE_PACKAGE_ID` remains unchanged;
- Mission Read backend and repository surfaces remain unchanged;
- no governance lifecycle state is created or modified.

LIVE_UI_FULL_DASHBOARD_REQUIRED=YES
PREPARING_STATE_REGRESSION_ALLOWED=NO
CROSS_PROJECT_RESULT_ACCEPTANCE_ALLOWED=NO

## Next Action

Protect this alternative classification with DR.

Only after that checkpoint may explicit implementation authorization be considered for:

MISSION_READ_CLIENT_EXPECTED_PROJECT_VALIDATION

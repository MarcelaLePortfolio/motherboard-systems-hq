# PHASE 64.6 — WORKSPACE INTERACTIVITY CONTRACT LOCK

Date: 2026-03-14

## PURPOSE

Protect the dashboard against regressions where it still renders visually but no longer behaves like an interactive operator console.

This contract formalizes the required behavior for:

- dashboard finishing load
- workspace tabs remaining clickable
- exactly one active panel per workspace
- Task Events tab remaining interactive
- no hidden replay storm silently degrading the UI

## CONTRACT RULES

### 1. INTERACTIVITY IS A FIRST-CLASS INVARIANT

A dashboard change is not valid unless the page:

- finishes loading
- allows tab switching
- shows only the intended active panel
- preserves Task Events interactivity

Visual render alone is insufficient.

### 2. EXACTLY ONE ACTIVE PANEL PER WORKSPACE

For each tabbed workspace:

- exactly one visible active panel is allowed
- inactive panels must not remain visually present
- switching tabs must not duplicate, merge, or stack panel content

### 3. TASK EVENTS MUST NOT DEGRADE DASHBOARD INTERACTIVITY

Task Events changes must never:

- block page load completion
- freeze tab switching
- create replay storms
- cause the dashboard to become visually present but operationally dead

### 4. REPLAY STORM PREVENTION IS MANDATORY

A healthy idle `/events/task-events` stream is:

- `hello`
- `heartbeat`
- more `heartbeat`

This is valid and healthy.

A replay storm is defined as repeated re-emission of the same event id on a live idle stream.

Replay storms are contract failures even if the page still renders.

### 5. NEVER PATCH FORWARD WHEN INTERACTIVITY BREAKS

If any dashboard change causes:

- tabs to stop responding
- page load to never finish
- Task Events to break interactivity
- panel visibility logic to collapse

then:

1. revert immediately to the last interactive baseline
2. confirm dashboard health
3. rerun regression guards
4. apply one narrow fix only

### 6. REQUIRED VERIFICATION AFTER ANY RELATED CHANGE

After any change affecting:

- dashboard tabs
- workspace panels
- task-events stream
- task-events mount path
- task-events styling that could affect mounting or visibility
- dashboard boot sequence

the operator must run:

bash scripts/_local/phase64_5_task_events_contract_guard.sh
bash scripts/_local/phase64_6_workspace_interactivity_contract_guard.sh

The change is not complete until both pass and the manual UI verification is performed.

### 7. REQUIRED MANUAL UI VERIFICATION

Always open a cache-busted dashboard URL and confirm:

- dashboard finishes loading
- tabs are clickable
- switching tabs changes visible content correctly
- Task Events tab remains interactive
- no replay storm is occurring

### 8. SCOPE OF THIS CONTRACT

This contract governs:

- operator workspace tabs
- telemetry workspace tabs
- dashboard tab mounting behavior
- task-events tab interaction safety

This contract does not replace the layout contract.
It extends protection from structure into behavior.

## HEALTHY STATE DEFINITION

A healthy workspace-interactive dashboard satisfies all of the following:

- `/dashboard` returns HTTP 200
- page load completes
- tab controls exist
- tab controls can be clicked
- only one active panel per workspace is visible
- Task Events tab can be opened without freezing the page
- task-events regression guard shows no replay storm
- idle task-events stream may show only hello + heartbeats

## FAILURE CLASSIFICATION

### Cosmetic failure
Examples:
- panel height mismatch
- spacing inconsistency
- uneven card sizing

These may be deferred if interactivity remains intact.

### Contract failure
Examples:
- page does not finish loading
- tabs stop responding
- multiple panels remain visible at once
- Task Events freezes due to replay storm
- active tab becomes non-interactive

These require immediate rollback or narrow repair.

## OPERATOR PROCEDURE

When workspace interactivity regresses:

1. run task-events regression guard
2. run workspace interactivity guard
3. classify whether failure is:
   - endpoint replay
   - tab visibility logic
   - mount path breakage
   - load/interactivity breakage
4. if interactivity is broken, revert immediately
5. apply one narrow fix
6. rerun both guards
7. perform manual cache-busted UI verification

## STATUS

Phase 64.6 workspace interactivity contract is now considered locked once committed.
Any future related work should treat this document as a protected behavioral contract.

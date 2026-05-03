# PHASE 64.8 — PRE-PUSH CONTRACT GUARD

Date: 2026-03-14

## PURPOSE

This guard turns the Phase 64 protection corridor into a routine pre-push safety check.

It is intended for any change that touches one or more of the following:

- dashboard layout
- workspace tabs/panels
- task-events rendering
- task-events SSE route behavior
- task-events mount path
- dashboard interactivity behavior

## REQUIRED RUN

Before pushing risky dashboard or task-events changes, run:

bash scripts/_local/phase64_8_pre_push_contract_guard.sh

## INCLUDED CHECKS

The runner executes these protections in order:

1. stray shell artifact cleanup
2. task-events replay regression guard
3. task-events contract guard
4. workspace interactivity contract guard
5. layout/script mount guard

## WHAT THIS PREVENTS

This corridor is intended to catch regressions such as:

- replay storm caused by broken task-events cursor math
- dashboard no longer finishing load
- tabs becoming non-clickable
- Task Events becoming non-interactive
- broken recovery hook accidentally re-mounted
- missing required scripts
- duplicate task-events mount anchor in dashboard HTML
- stray shell artifacts polluting the repo after failed command pastes

## INTERPRETATION

### PASS
A pass means:

- dashboard endpoint responds
- idle task-events stream is healthy
- protected dashboard scripts are present
- broken recovery hook is absent
- protected workspace anchors are present
- task-events mount anchor is unique
- routine safety corridor completed without failing

### STILL REQUIRED
A pass does not replace final manual UI verification.

After the runner opens a cache-busted dashboard page, still confirm:

- dashboard finishes loading
- tabs are clickable
- only one intended panel is visible per workspace
- Task Events remains interactive
- no replay storm appears in the UI

## OPERATOR RULE

For risky dashboard/task-events work:

1. make one narrow change
2. run the pre-push contract guard
3. do manual UI verification
4. only then push

If interactivity breaks at any point:

- revert immediately to the last interactive baseline
- do not patch forward
- classify the failure source before attempting another fix

## STATUS

Phase 64.8 pre-push contract guard is now part of the routine protective corridor.

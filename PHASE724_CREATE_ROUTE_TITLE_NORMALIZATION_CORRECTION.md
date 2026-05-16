
# Phase 724 Create Route Title Normalization Correction

## Objective

Correct the previous failed patch attempt and actually apply task title normalization.

## Previous Issue

The first patch script failed with:

`Could not find create-route body insertion point.`

That commit added documentation and a failed helper script, but did not mutate the route.

## Correction

Applied whitespace-tolerant patch script:

`patch_phase724_create_route_title_v2.py`

## Changed File

`server/routes/api-tasks-postgres.mjs`

## Confirmed Insert

`const taskTitle = (...)`

## Confirmed Usage

`taskTitle ? String(taskTitle) : null`

is now used for:

- task row title

- task.created event title

## Removed

Failed helper script:

`patch_phase724_create_route_title.py`

## Validation

Syntax check:

`node --check server/routes/api-tasks-postgres.mjs`

## Next Step

Rebuild dashboard service because `/api/tasks/create` lives in dashboard runtime, then re-test natural delegation.


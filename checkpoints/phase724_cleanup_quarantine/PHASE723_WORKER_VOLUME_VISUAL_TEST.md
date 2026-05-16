
# Phase 723 Worker Volume Visual Test

## Objective

Use the worker container to write the controlled Phase 723 visual marker test artifact because the dashboard container has read-only access to artifact storage.

## Previous Finding

Dashboard write attempt failed with:

`Read-only file system`

This confirms dashboard artifact access remains read-only, which is correct for preview safety.

## Corrected Test Path

Write test content from the worker container to:

`/app/data/artifacts/t_4b5bae1d-c104-48c6-b591-da5dd27f5744_run_c224f008-8287-4158-a226-473d607df82f.md`

Then verify through dashboard read-only route:

`/api/tasks/t_4b5bae1d-c104-48c6-b591-da5dd27f5744/artifact-preview`

## Expected Route Markers

The artifact-preview route should contain:

- `visual-artifact:start`

- `Phase 723 Runtime Validation`

- `Visual marker renderer validation`

## Browser Validation

Open Preview for:

`t_4b5bae1d-c104-48c6-b591-da5dd27f5744`

Confirm:

- Visual Artifact block appears

- semantic fallback remains underneath

- no duplicate preview stack appears

- no console errors appear

## Contract Preservation

This preserves:

- dashboard read-only artifact route

- backend routes

- worker code

- retry contract

- SSE pipeline

- DB schema

- task polling

- Agent Pool refresh behavior

## Interpretation

If route markers exist and browser visual card appears, Phase 723 visual renderer passes.


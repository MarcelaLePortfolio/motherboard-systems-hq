
# Phase 724 Title Normalization Runtime Test

## Objective

Validate that `/api/tasks/create` now preserves natural-language delegation text when it arrives as `description`.

## Rebuilt Service

`dashboard`

## Test Request

`Create a visual launch card for Moonrise Bakery`

Sent as:

`description`

## Expected Result

The created task should no longer show:

`Untitled task`

Expected worker behavior:

- task title persists

- visual intent is detected

- `strategy_applied` becomes `visual_artifact_generation`

- preview artifact contains Phase 723 markers

- Preview renders the Visual Artifact card

## Contract Preservation

No changes to renderer, preview route, retry, SSE, DB schema, polling, or Agent Pool behavior.



# Phase 724 Create Route Title Normalization

## Objective

Prevent delegated natural-language task text from being lost when it arrives as a field other than `title`.

## Changed File

`server/routes/api-tasks-postgres.mjs`

## Change

Added `taskTitle` normalization from:

- `title`

- `description`

- `prompt`

- `input`

- `message`

- `task`

- matching nested `payload` fields

## Used In

- `tasks.title`

- `task.created` event payload title

## Reason

The failed Phase 724 natural visual delegation task stored:

- empty title

- empty payload

so the worker saw only:

`Untitled task`

## Preservation

No changes to renderer, preview route, retry, SSE, DB schema, polling, or Agent Pool behavior.


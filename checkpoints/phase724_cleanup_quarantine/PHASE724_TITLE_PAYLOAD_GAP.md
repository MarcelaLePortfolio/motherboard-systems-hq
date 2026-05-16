
# Phase 724 Title Payload Gap

## Finding

The natural visual delegation test did not activate visual generation.

## Evidence

Created task:

`t_dfb0d1f5-dc5f-4d48-b244-5fea1b4e0096`

Result showed:

- `title: null`

- `outcome_preview: Standard execution prepared for: Untitled task`

- `strategy_applied: default`

## Interpretation

The interpreter patch is present, but the interpreter is only checking:

`task.title || payload.title || "Untitled task"`

The dashboard delegation path is creating a task whose visible natural-language request is not available in those fields for this API shape.

## Required Fix

Inspect broader payload/request fields before visual intent detection.

Candidate fields:

- `payload.description`

- `payload.task`

- `payload.prompt`

- `payload.input`

- `payload.message`

- `task.description`

- `task.prompt`

- `task.input`

## Scope

Patch interpreter request text extraction only.

Do not modify renderer, preview route, retry, SSE, DB, polling, or Agent Pool behavior.


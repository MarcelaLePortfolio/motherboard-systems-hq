
# Phase 724 Delegation Visual Generation Gap

## Finding

Phase 723 frontend rendering is validated, but delegation-generated visual artifacts are not yet truly generative.

## Evidence

Delegated task:

`Create a previewable visual artifact demo for Moonrise Bakery...`

Result:

- Visual Artifact container rendered

- marker extraction worked

- sanitized rendering path worked

- but content inside the visual block was literal placeholder text:

`[a polished HTML visual card for Moonrise Bakery]`

## Interpretation

This is not a Phase 723 renderer failure.

This is a worker/delegation artifact-generation gap.

The worker preserved the marker contract but did not synthesize the requested HTML visual card.

## Required Phase 724 Target

Make visual artifact generation automatic from natural delegation intent.

The user should be able to delegate:

`Create a visual landing card for Moonrise Bakery.`

The system should internally produce:

- marker-wrapped embedded HTML

- semantic markdown fallback

- preview-safe visual card

- no user-facing marker requirement

## Phase 724 Scope

Inspect and update the worker artifact-generation layer so it can:

1. detect visual artifact intent

2. synthesize a safe HTML visual block

3. wrap it in Phase 723 markers internally

4. preserve markdown fallback sections

5. avoid exposing marker syntax to the operator

## Forbidden Scope

Do not modify:

- Phase 723 renderer

- artifact preview route

- retry contract

- SSE pipeline

- DB schema

- task polling

- Agent Pool behavior

## Next Step

Inspect the worker artifact generation code and identify the safest prompt/template insertion point.


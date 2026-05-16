
# Phase 724 Visual Intent Patch Plan

## Goal

Enable delegated natural-language visual requests to automatically generate previewable visual artifacts.

Example:

`Create a visual launch card for Moonrise Bakery.`

## Target

`server/worker/task_execution_interpreter.mjs`

## Safe Strategy

Add a narrow visual-intent branch before the existing default return path.

The branch should:

- detect obvious visual requests

- generate safe embedded HTML

- wrap output with:

  - `<!-- visual-artifact:start -->`

  - `<!-- visual-artifact:end -->`

- preserve markdown fallback sections

## Non-Goals

Do not modify:

- renderer

- preview route

- artifact writer

- retry contract

- SSE

- DB schema

- polling

- Agent Pool behavior

## Safety Boundary

If visual intent is not confidently detected, preserve existing behavior exactly.



# Phase 724 Visual Intent Runtime Validation

## Objective

Validate that natural delegation requests can produce Phase 723-compatible visual artifacts without the user manually including visual markers.

## Rebuilt Service

`worker`

## Test Delegation

`Create a visual launch card for Moonrise Bakery`

## Expected Behavior

The worker should detect visual intent and produce:

- `strategy_applied: visual_artifact_generation`

- marker-wrapped visual HTML

- markdown fallback sections

- previewable artifact content

## Validation Target

Open Preview for the newly created task and confirm:

- Visual Artifact card appears

- semantic fallback remains

- raw marker text does not appear

- user did not need to include marker syntax

## Contract Preservation

No changes to:

- renderer

- preview route

- retry contract

- SSE

- DB schema

- polling

- Agent Pool behavior


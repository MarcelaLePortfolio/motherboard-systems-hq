
# Phase 723 Local Artifact Overwrite Test

## Objective

Validate the frontend Phase 723 visual marker renderer without changing worker contracts.

## Reason

The worker-generated runtime task completed, but it did not preserve the requested title or visual markers.

This confirms a worker artifact-generation limitation, not a renderer result.

## Test Method

Overwrite only the existing test artifact file inside the shared artifact volume with controlled marker content.

## Target Task

`t_4b5bae1d-c104-48c6-b591-da5dd27f5744`

## Target Artifact

`/app/data/artifacts/t_4b5bae1d-c104-48c6-b591-da5dd27f5744_run_c224f008-8287-4158-a226-473d607df82f.md`

## Validation

The artifact-preview route should now contain:

- `<!-- visual-artifact:start -->`

- `Phase 723 Runtime Validation`

- `Visual marker renderer validation`

## Browser Validation

Open Preview for the same task and confirm:

- Visual Artifact card appears above semantic fallback

- semantic fallback still appears

- no duplicate preview stack appears

- no console errors appear

## Contract Preservation

This does not modify:

- backend routes

- worker code

- retry contract

- SSE pipeline

- DB schema

- task polling

- Agent Pool refresh behavior

## Interpretation

If this Preview renders correctly, Phase 723 frontend visual renderer is validated.

If this Preview does not render the visual block even though artifact-preview contains the markers, the renderer activation requires correction.


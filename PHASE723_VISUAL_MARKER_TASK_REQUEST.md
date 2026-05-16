
# Phase 723 Visual Marker Task Request

## Objective

Create a real worker-generated task artifact that contains Phase 723 visual markers, so the browser Preview can validate the activated visual rendering path.

## API Route Used

`POST /api/tasks/create`

## Task Title

`Phase 723 visual marker runtime validation`

## Task Requirement

The task asks the worker to create a markdown artifact containing both markers:

`<!-- visual-artifact:start -->`

`<!-- visual-artifact:end -->`

Inside the markers, the artifact should include a simple styled visual block containing:

`Phase 723 Visual Artifact Runtime Test`

After the marker block, the artifact should include markdown sections:

- Summary

- Deliverable

- Outcome

- Next Steps

## Validation Goal

Once the task completes, open its Preview and confirm:

- Visual Artifact block appears above semantic fallback

- semantic fallback remains visible

- no duplicate preview regression appears

- no browser console errors appear

- no iframe/srcdoc rendering is used

## Contract Preservation

This uses the existing task creation API only.

No code mutation is introduced by this checkpoint.

## Next Safe Step

After the task completes, open Preview in the browser and validate the rendered visual marker path.



# Phase 723 Visual Wrapper Activation Correction

## Objective

Correct the previous activation attempt by applying the exact one-line mutation required for the current renderer shape.

## Changed File

`public/js/phase530_visible_panels_bridge.js`

## Actual Code Change

Inside:

`phase719RenderMarkdownArtifactPreview(markdown)`

Replaced:

`const rendered = phase719RenderArtifactVisualCard(markdown);`

with:

`const rendered = phase723RenderVisualArtifactPreviewCandidate(markdown);`

## Preservation Logic

The wrapper preserves the existing semantic fallback when no visual marker exists.

Visual rendering only activates when both markers are present:

`<!-- visual-artifact:start -->`

`<!-- visual-artifact:end -->`

## Validation Performed

- JavaScript syntax check

- renderer snippet inspection

- Docker service health check

- dashboard route smoke test

## Contract Preservation

This correction does not modify:

- backend routes

- worker persistence

- retry contract

- SSE pipeline

- DB schema

- artifact preview route

- task polling

- Agent Pool refresh behavior

## Required Browser Validation

Validate:

1. dashboard loads

2. Recent Tasks loads

3. existing Preview opens

4. existing semantic artifact renders

5. no duplicate rendering appears

6. Agent Pool refresh persistence remains stable

7. browser console has no Phase 723 errors

## Rollback Boundary

If browser validation fails, revert this correction commit only.



# Phase 723 Browser Validation Checkpoint

## Objective

Validate the newly activated visual artifact preview wrapper in the served browser runtime.

## Activated Commit

`da622425`

## Activated Renderer Path

Inside:

`public/js/phase530_visible_panels_bridge.js`

The renderer now calls:

`phase723RenderVisualArtifactPreviewCandidate(markdown)`

from:

`phase719RenderMarkdownArtifactPreview(markdown)`

## Expected Existing Artifact Behavior

Existing markdown artifacts without visual markers should still render through the same semantic fallback path.

Expected behavior:

- Preview modal opens

- semantic visual card renders

- markdown fallback remains readable

- no duplicate semantic rendering appears

- no visual artifact card appears unless markers exist

- no console error appears

## Expected Visual Marker Behavior

Artifacts containing both markers should render a Visual Artifact block above the semantic fallback:

`<!-- visual-artifact:start -->`

`<!-- visual-artifact:end -->`

The visual block should be sanitized before rendering.

## Manual Browser Validation Steps

1. Open dashboard at `http://localhost:3000`

2. Confirm Recent Tasks renders

3. Open Preview for an existing completed artifact

4. Confirm existing semantic artifact rendering still appears

5. Confirm no duplicate rendering regression

6. Confirm Agent Pool remains visible after refresh

7. Open browser console

8. Confirm no Phase 723 JavaScript errors

9. If a visual-marker artifact exists, open Preview and confirm visual card appears

10. Confirm markdown fallback still appears under the visual card

## Current Validation Status

Pending browser validation.

## Pass Criteria

This checkpoint passes only if:

- existing artifacts render unchanged

- visual wrapper does not break markdown-only previews

- dashboard remains responsive

- no console errors appear

- refresh persistence remains stable

## Failure Boundary

If any browser regression appears, revert commit:

`da622425`

and return to the corrected inactive-wrapper baseline.


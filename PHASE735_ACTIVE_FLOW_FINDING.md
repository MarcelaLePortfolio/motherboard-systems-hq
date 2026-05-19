
# Phase 735 Active Flow Finding

## Browser Evidence

Runtime script content check confirms the browser-loaded script contains:

- `data-phase735-visual-html-mount`

- `data-phase735-visual-html-template`

- `phase735DecodeVisualArtifactHtmlTransport`

The loaded script also still contains the old helper marker:

- `sanitized html subset`

## Interpretation

The browser is loading the current script, but the active preview flow is still reaching the old visual wrapper/helper path instead of the single-container render branch.

This is an active-flow branch-selection issue, not:

- stale browser cache

- stale dashboard image

- stale worker image

- missing Phase 735 code

## Next Investigation Target

`phase719RenderMarkdownArtifactPreview()` branch order and its caller.

Specifically verify why raw artifact previews still enter:

- `phase723RenderVisualArtifactPreviewCandidate()`

instead of:

- `data-phase733-single-artifact-render`

## Boundary

No speculative renderer mutation until the branch path is confirmed.


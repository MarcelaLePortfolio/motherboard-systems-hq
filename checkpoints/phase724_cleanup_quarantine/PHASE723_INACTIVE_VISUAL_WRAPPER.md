
# Phase 723 Inactive Visual Wrapper

## Objective

Add a non-active visual rendering wrapper that combines visual block extraction, sanitizer usage, and markdown fallback preservation.

## Changed File

`public/js/phase530_visible_panels_bridge.js`

## Added Helper

`phase723RenderVisualArtifactPreviewCandidate(markdown)`

## Helper Behavior

The helper:

1. extracts a bounded visual artifact block

2. preserves markdown without the visual block

3. renders the existing semantic fallback through `phase719RenderArtifactVisualCard`

4. sanitizes the visual HTML subset

5. returns visual preview plus fallback only when a valid visual block exists

6. returns existing fallback rendering when no visual block exists

## Activation State

The helper is intentionally inactive.

The live Preview path still uses:

`phase719RenderMarkdownArtifactPreview(data.content)`

The live markdown renderer still uses:

`phase719RenderArtifactVisualCard(markdown)`

## Contract Preservation

This change does not modify:

- artifact preview fetch route

- Preview modal lifecycle

- final `body.innerHTML` assignment

- worker persistence

- retry architecture

- SSE pipeline

- DB schema

- task polling

- Agent Pool refresh behavior

## Validation

Syntax validation was run:

`node --check public/js/phase530_visible_panels_bridge.js`

Helper ordering confirmed by grep.

## Next Safe Step

Perform dashboard rebuild/runtime validation before activating the wrapper in `phase719RenderMarkdownArtifactPreview`.

## Rollback Boundary

If syntax, dashboard rebuild, or runtime validation fails, revert this commit before any further Phase 723 work.


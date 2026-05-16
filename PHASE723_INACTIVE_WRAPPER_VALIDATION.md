
# Phase 723 Inactive Wrapper Validation

## Objective

Validate the inactive visual preview wrapper before any live rendering activation.

## Validated Commit

`f90766c4`

## Validated File

`public/js/phase530_visible_panels_bridge.js`

## Validation Commands

- `node --check public/js/phase530_visible_panels_bridge.js`

- `npm run build`

- `docker compose ps`

- `curl -sS http://localhost:3000/ | head -20`

## Expected Validation Result

Validation should confirm:

- JavaScript syntax passes

- dashboard build passes

- Docker services remain healthy

- dashboard route responds

- inactive visual wrapper does not affect live rendering

- Preview modal activation path remains unchanged

## Current Live Rendering Path

Still authoritative:

`body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content)`

Still authoritative:

`phase719RenderMarkdownArtifactPreview(markdown)`

Still authoritative fallback:

`phase719RenderArtifactVisualCard(markdown)`

## Contract Preservation

This validation does not mutate:

- backend routes

- worker persistence

- retry contract

- SSE pipeline

- DB schema

- artifact preview route

- task polling

- Agent Pool refresh behavior

## Next Safe Step

If validation passes, activate the wrapper by changing only the internals of:

`phase719RenderMarkdownArtifactPreview(markdown)`

The activation must preserve fallback behavior when no visual marker exists.

## Rollback Boundary

If build or runtime validation fails, revert commit `f90766c4`.


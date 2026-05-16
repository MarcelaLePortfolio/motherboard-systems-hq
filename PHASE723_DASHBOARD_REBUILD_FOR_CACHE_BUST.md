
# Phase 723 Dashboard Rebuild for Cache Bust

## Objective

Rebuild the dashboard service because container restart did not serve the cache-busted renderer script reference.

## Finding

After cache-bust commit and dashboard restart, served HTML still showed:

`<script defer src="js/phase530_visible_panels_bridge.js"></script>`

This means the running dashboard container is serving image-copied HTML rather than the updated host `public/index.html`.

## Required Action

Rebuild only the dashboard service:

`docker compose up -d --build dashboard`

## Validation Commands

- inspect served HTML for cache-busted renderer script

- inspect cache-busted JS URL for Phase 723 activation strings

- confirm Docker service health

## Expected Served HTML

`js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper`

## Expected Served JS

- `phase723RenderVisualArtifactPreviewCandidate`

- `const rendered = phase723RenderVisualArtifactPreviewCandidate`

- `visual-artifact:start`

## Contract Preservation

This rebuild targets only the dashboard service.

It does not modify:

- worker code

- postgres data

- backend contracts

- retry contract

- SSE pipeline

- DB schema

- artifact preview route

- task polling

- Agent Pool behavior

## Next Safe Step

Only after served HTML confirms the cache-busted script should browser validation proceed.


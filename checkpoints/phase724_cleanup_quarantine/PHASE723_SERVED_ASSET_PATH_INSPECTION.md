
# Phase 723 Served Asset Path Inspection

## Objective

Verify the actual script path referenced by the served dashboard HTML before browser validation.

## Reason

The dashboard container source contains the Phase 723 activation, but previous HTTP grep checks did not print expected strings.

This suggests the active browser-served asset path may differ from the assumed path:

`/js/phase530_visible_panels_bridge.js`

## Inspection Commands

- inspect served dashboard HTML for the renderer script path

- inspect served HTML script tags

- search container files for renderer references

- check byte size of assumed served JS path

- inspect head of assumed served JS path

## Interpretation

If served HTML references the expected path, browser validation may proceed after hard refresh.

If served HTML references a versioned or alternate path, verify that exact asset instead.

If assumed served JS path returns empty or unexpected content, inspect static routing before proceeding.

## Current Known State

Container source file is current and includes:

- `phase723RenderVisualArtifactPreviewCandidate`

- activation call inside `phase719RenderMarkdownArtifactPreview`

## Contract Preservation

This inspection does not modify:

- backend routes

- worker persistence

- retry contract

- SSE pipeline

- DB schema

- artifact preview route

- task polling

- Agent Pool refresh behavior

## Next Safe Step

Once the active served script path is confirmed, proceed to manual browser validation.


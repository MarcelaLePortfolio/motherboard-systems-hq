
# Phase 724 Visual Fallback Suppression

## Objective

Suppress redundant semantic fallback from the primary Preview view when a visual artifact block is present.

## Changed File

`public/js/phase530_visible_panels_bridge.js`

## Behavior Change

When visual artifact markers are detected:

- render the Visual Artifact card

- skip the Completion Summary / semantic fallback stack from primary view

When no visual artifact markers are detected:

- preserve the existing markdown/semantic fallback behavior

## Reason

Phase 724 natural visual delegation is browser-validated.

For visual artifacts, the fallback stack is now redundant in the primary operator Preview and creates visual clutter.

## Preservation

No changes to:

- worker generation

- artifact persistence

- artifact preview route

- retry contract

- SSE

- DB schema

- task polling

- Agent Pool behavior

## Validation

Syntax check:

`node --check public/js/phase530_visible_panels_bridge.js`

## Next Step

Rebuild dashboard and preview the existing visual artifact task.


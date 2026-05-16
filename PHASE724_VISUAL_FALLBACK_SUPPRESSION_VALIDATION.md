
# Phase 724 Visual Fallback Suppression Validation

## Objective

Validate served runtime after suppressing the semantic fallback stack for visual artifacts.

## Rebuilt Service

`dashboard`

## Expected Served Renderer

The served renderer should include:

- `data-phase724-visual-only-preview`

- `hasVisualArtifact`

## Browser Validation Target

Preview task:

`t_b23890b9-8159-4bb9-81b8-9a89fa514ffb`

## Expected Preview

For visual artifacts:

- Visual Artifact card appears

- Completion Summary / semantic fallback does not appear as a second primary section

- raw marker block does not appear

- no duplicate preview stack appears

- no console errors appear

## Non-Visual Preservation

For non-visual markdown artifacts:

- existing semantic fallback rendering should remain unchanged

## Contract Preservation

No changes to worker generation, artifact persistence, preview route, retry, SSE, DB schema, polling, or Agent Pool behavior.


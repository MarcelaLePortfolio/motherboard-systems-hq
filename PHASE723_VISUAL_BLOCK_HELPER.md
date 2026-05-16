
# Phase 723 Visual Block Helper

## Objective

Introduce the first rollback-safe Phase 723 code mutation by adding a non-active visual artifact block extraction helper to the authoritative renderer.

## Mutation Scope

Changed file:

`public/js/phase530_visible_panels_bridge.js`

Added helper:

`phase723ExtractVisualArtifactBlock(markdown)`

## Helper Behavior

The helper detects bounded visual artifact markers:

`<!-- visual-artifact:start -->`

`<!-- visual-artifact:end -->`

It returns:

- `hasVisualArtifact`

- `visualHtml`

- `markdownWithoutVisualArtifact`

## Activation State

The helper is intentionally non-active.

It is not yet connected to:

- Preview modal rendering

- semantic card rendering

- markdown fallback rendering

- artifact preview fetch handling

## Contract Preservation

This change does not modify:

- backend routes

- worker artifact persistence

- retry/requeue architecture

- SSE pipeline

- DB schema

- artifact preview route

- markdown fallback rendering

- semantic rendering output

## Next Safe Step

Run syntax/build/runtime validation before wiring the helper into any rendering path.

## Rollback Boundary

If any dashboard build or runtime instability appears, revert this commit immediately.


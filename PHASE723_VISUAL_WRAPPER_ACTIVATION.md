
# Phase 723 Visual Wrapper Activation

## Objective

Activate the Phase 723 visual artifact preview wrapper through the narrowest possible renderer mutation.

## Changed File

`public/js/phase530_visible_panels_bridge.js`

## Activation Change

Updated:

`phase719RenderMarkdownArtifactPreview(markdown)`

Previous internal call:

`phase719RenderArtifactVisualCard(markdown)`

New internal call:

`phase723RenderVisualArtifactPreviewCandidate(markdown)`

## Why This Is Safe

The wrapper preserves fallback behavior.

If no bounded visual artifact marker exists, the wrapper returns the existing semantic card rendering through:

`phase719RenderArtifactVisualCard(markdown)`

This means current markdown artifacts should continue rendering through the same semantic path.

## Visual Marker Required

Visual rendering activates only when artifact markdown contains both markers:

`<!-- visual-artifact:start -->`

`<!-- visual-artifact:end -->`

## Contract Preservation

This activation does not modify:

- Preview modal lifecycle

- artifact preview fetch route

- final `body.innerHTML` assignment

- backend routes

- worker persistence

- retry/requeue contracts

- SSE pipeline

- DB schema

- task polling

- Agent Pool refresh behavior

## Validation Performed

Validation commands:

- `node --check public/js/phase530_visible_panels_bridge.js`

- `grep -n "function phase719RenderMarkdownArtifactPreview" -A10 public/js/phase530_visible_panels_bridge.js`

- `docker compose ps`

- `curl -sS http://localhost:3000/ | head -20`

## Required Browser Validation

After this commit, validate manually in browser:

1. dashboard loads

2. Recent Tasks loads

3. Preview opens for existing markdown artifact

4. existing semantic artifact rendering is unchanged

5. no duplicate rendering appears

6. Agent Pool refresh persistence remains stable

7. no console error appears from Phase 723 helpers

## Rollback Boundary

If browser validation fails, revert this commit only and return to commit:

`c50001ba`


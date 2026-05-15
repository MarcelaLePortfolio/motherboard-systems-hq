
# Phase 720 Frontend Semantic Envelope Detection Plan

## Purpose

Add read-only frontend detection for the worker-authored `MB_SEMANTIC_ARTIFACT_V1` envelope without changing backend contracts.

## Stable Starting Point

- Current HEAD: `ce3cec86`

- Worker semantic envelope validated.

- Markdown fallback preserved.

- Artifact preview route preserved.

- Existing visual preview renderer stable.

## Allowed Next Mutation

Patch only:

- `public/js/phase530_visible_panels_bridge.js`

## Required Behavior

- Detect `MB_SEMANTIC_ARTIFACT_V1` only if present.

- Parse semantic JSON only if valid.

- Ignore envelope safely if missing or malformed.

- Keep existing markdown section parser as fallback.

- Render existing preview UI without breaking legacy artifacts.

- Do not change backend routes.

- Do not change worker output.

- Do not change DB schema.

- Do not change SSE or retry contracts.

## Success Criteria

- Legacy artifacts still preview.

- Fresh Phase 720 artifacts still preview.

- Semantic envelope can be detected in frontend code path.

- No runtime crash.

- No polling regression.

- No Agent Pool regression.

## Rollback Boundary

If preview modal breaks or task polling regresses, revert frontend patch immediately and return to `ce3cec86`.


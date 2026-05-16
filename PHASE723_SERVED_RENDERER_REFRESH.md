
# Phase 723 Served Renderer Refresh

## Objective

Refresh the dashboard container after served renderer verification did not show Phase 723 activation strings.

## Reason

Previous served renderer verification showed Docker services were healthy, but the expected Phase 723 strings were not visible in the command output.

This indicates the served dashboard asset may not yet reflect the current source file.

## Refresh Command

`docker compose restart dashboard`

## Verification Commands

- `curl -sS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "phase723RenderVisualArtifactPreviewCandidate" | head -5`

- `curl -sS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "phase723SanitizeVisualArtifactHtml" | head -5`

- `curl -sS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "visual-artifact:start" | head -5`

- `docker compose ps`

## Expected Result

The served renderer should expose the Phase 723 helper and activation strings after dashboard refresh.

## Interpretation

If strings appear, browser validation may proceed.

If strings still do not appear, do not proceed with browser validation. Inspect Docker volume/build behavior before further rendering work.

## Contract Preservation

This step does not modify:

- backend routes

- worker persistence

- retry contract

- SSE pipeline

- DB schema

- artifact preview route

- task polling

- Agent Pool refresh behavior

## Next Safe Step

Proceed only after served JS confirms the Phase 723 activation is live.


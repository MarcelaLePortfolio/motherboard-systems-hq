
# Phase 723 Served Renderer Verification

## Objective

Verify that the Docker-served dashboard JavaScript includes the Phase 723 visual wrapper activation before manual browser validation.

## Verification Target

Served file:

`http://localhost:3000/js/phase530_visible_panels_bridge.js`

## Verification Commands

- `curl -sS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "phase723RenderVisualArtifactPreviewCandidate" | head -5`

- `curl -sS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "phase723SanitizeVisualArtifactHtml" | head -5`

- `curl -sS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "visual-artifact:start" | head -5`

- `docker compose ps`

## Expected Result

The served JS should contain:

- `phase723RenderVisualArtifactPreviewCandidate`

- `phase723SanitizeVisualArtifactHtml`

- `visual-artifact:start`

- healthy Docker services

## Interpretation

If these strings are present in the served JS, the dashboard container is serving the Phase 723 renderer activation.

If absent, rebuild/restart the dashboard container before browser validation.

## Next Safe Step

After served renderer verification passes:

1. hard refresh dashboard

2. open an existing artifact Preview

3. confirm existing markdown/semantic rendering still works

4. confirm no browser console errors

5. then test visual-marker artifact behavior separately

## Rollback Boundary

If served renderer is current but browser preview breaks, revert activation commit `da622425`.


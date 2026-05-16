
# Phase 723 Renderer Cache Bust

## Objective

Force the browser to load the activated Phase 723 renderer instead of a cached copy.

## Reason

Manual browser validation showed visual markers rendering as raw markdown inside the semantic fallback.

Because the artifact-preview route contains the markers and the source/container renderer contains the Phase 723 wrapper, the likely failure point is browser-side cached JavaScript.

## Changed Files

- `public/index.html`

- `public/dashboard.html`

## Change

Updated renderer script reference to:

`js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper`

## Expected Result

After dashboard reload and browser hard refresh:

- Phase 723 renderer loads fresh

- visual marker block is extracted

- Visual Artifact card appears above fallback

- raw marker block no longer appears inside Summary

- semantic fallback remains visible

- no duplicate preview stack appears

## Contract Preservation

This change does not modify:

- backend routes

- worker code

- artifact preview route

- retry contract

- SSE pipeline

- DB schema

- task polling

- Agent Pool behavior

## Browser Validation

After this commit:

1. hard refresh dashboard

2. open Preview for `t_4b5bae1d-c104-48c6-b591-da5dd27f5744`

3. confirm the Visual Artifact card appears above semantic fallback

4. confirm raw marker HTML is no longer displayed in Summary

5. confirm no console errors

## Rollback Boundary

If browser validation still fails after cache bust, inspect served HTML and active script execution before further renderer mutation.


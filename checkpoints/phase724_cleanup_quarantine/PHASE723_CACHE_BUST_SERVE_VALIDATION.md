
# Phase 723 Cache Bust Serve Validation

## Objective

Confirm the running dashboard serves the Phase 723 cache-busted renderer script reference.

## Required Served HTML Reference

Expected served script reference:

`js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper`

## Validation Commands

- restart dashboard container

- inspect served HTML for cache-busted renderer script

- inspect cache-busted JS URL for Phase 723 activation strings

- confirm Docker service health

## Expected Result

Served HTML should include:

`phase530_visible_panels_bridge.js?v=phase723-visual-wrapper`

Served JS should include:

- `phase723RenderVisualArtifactPreviewCandidate`

- `const rendered = phase723RenderVisualArtifactPreviewCandidate`

- `visual-artifact:start`

## Manual Browser Validation

After this checkpoint:

1. hard refresh `http://localhost:3000`

2. open Preview for `t_4b5bae1d-c104-48c6-b591-da5dd27f5744`

3. confirm visual card appears above fallback

4. confirm raw marker HTML no longer appears in Summary

5. confirm no browser console errors

## Contract Preservation

This validation does not modify:

- backend routes

- worker code

- artifact preview route

- retry contract

- SSE pipeline

- DB schema

- task polling

- Agent Pool behavior

## Rollback Boundary

If served HTML is updated but browser validation still shows raw marker text, inspect active browser script execution before further code mutation.


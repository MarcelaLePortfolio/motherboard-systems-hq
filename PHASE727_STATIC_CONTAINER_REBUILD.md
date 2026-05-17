
# Phase 727 — Static Container Rebuild Validation

## Failure

The semantic observability HTML file exists in the repository but was not present in the running dashboard container at:

/app/public/devtools/semantic-observability.html

## Classification

CONTAINER IMAGE STALENESS / STATIC ASSET NOT PRESENT IN RUNNING DASHBOARD IMAGE

## Safe Fix

Rebuild and recreate only the dashboard service.

## Boundaries Preserved

- No worker mutation

- No Preview mutation

- No renderer mutation

- No retry mutation

- No SSE mutation

- No database mutation

- No semantic schema mutation


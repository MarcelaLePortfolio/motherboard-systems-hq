
# Phase 727 — Semantic Observability Validation

## Current Branch

phase727-semantic-observability

## Latest Known Commit

4d097ae8 Phase 727: add read-only semantic observability surface

## Validation Target

/public/devtools/semantic-observability.html

## Contract Boundaries Preserved

- No renderer authority added

- No Preview mutation

- No retry mutation

- No SSE mutation

- No task execution mutation

- No database mutation

- No orchestration coupling

## Manual Validation Commands

docker compose ps

curl -I http://localhost:3000/devtools/semantic-observability.html

curl -s http://localhost:3000/devtools/semantic-observability.html | head -40

curl -s http://localhost:3000/api/tasks | python3 -m json.tool | head -80

## Browser Validation

Open:

http://localhost:3000/devtools/semantic-observability.html

Expected result:

- Page loads

- READ-ONLY INSPECTION SURFACE banner visible

- Recent task cards render

- Semantic metadata is shown only if present

- No Preview behavior changes

- No task lifecycle behavior changes

## Stability Rule

If the page fails to load, inspect static serving path first.

Do not mutate:

- worker

- renderer

- retry architecture

- Preview modal

- artifact preview endpoint


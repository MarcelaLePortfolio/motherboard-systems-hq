
# PHASE 719 — RENDERER INSPECTION COMMANDS

## PURPOSE

This checkpoint defines the next safe read-only inspection pass before any embedded renderer mutation.

## CURRENT AUTHORITATIVE HEAD

`6aab261a`

## READ-ONLY INSPECTION COMMANDS

Run these before editing:

```bash

git status --short

git log --oneline --decorate -5

grep -n "artifact-preview\|srcdoc\|iframe\|Preview\|modal\|artifact" public/js/phase530_visible_panels_bridge.js | head -80

grep -n "function.*artifact\|render.*artifact\|preview.*artifact\|srcdoc" public/js/phase530_visible_panels_bridge.js | head -80

docker compose ps

curl -s http://localhost:3000/ | head

curl -s http://localhost:3000/api/tasks | head

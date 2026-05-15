
# Phase 721 Semantic Visual Enrichment Baseline

## Purpose

Begin Phase 721 from the browser-validated Phase 720 semantic artifact completion seal.

Phase 721 must remain UI-only and semantic-aware, without changing artifact contracts, worker output, database schema, routes, retry behavior, SSE behavior, or markdown fallback.

## Authoritative Starting Point

- Current stable HEAD: `e2097e91`

- Phase 720 completed and browser-validated.

- Worker-authored `MB_SEMANTIC_ARTIFACT_V1` envelope operational.

- Frontend semantic envelope detection operational.

- `semantic v1.0` chip browser-visible.

- Markdown fallback preserved.

- Legacy artifact rendering preserved.

- External archive completed.

## Allowed Phase 721 Scope

Allowed:

- semantic-aware badge labels

- semantic-aware artifact card readability

- semantic-aware visual grouping

- semantic-aware section prioritization

- semantic-aware operator summary display

- UI-only interpretation of already-detected semantic envelope

Not allowed:

- no worker artifact mutation

- no artifact preview route mutation

- no DB schema mutation

- no SSE mutation

- no retry architecture mutation

- no task polling mutation

- no iframe/srcdoc reactivation

- no markdown fallback removal

- no contract replacement

## Initial Safe Mutation Candidate

Patch only:

`public/js/phase530_visible_panels_bridge.js`

Goal:

Use the already-parsed semantic envelope to add a small semantic operator summary area inside the visual artifact card.

The summary must be additive and optional.

Fallback behavior:

- If semantic envelope is missing, render exactly through the existing markdown-derived path.

- If semantic envelope is malformed, ignore it.

- If semantic envelope exists, display concise operator-ready metadata without exposing raw JSON.

## Success Criteria

- Dashboard remains healthy.

- Fresh semantic artifacts still preview.

- Legacy artifacts still preview.

- Semantic chip still appears for Phase 720 artifacts.

- No raw semantic envelope appears in visual preview.

- Operator summary appears only when semantic envelope exists.

- Markdown section cards remain visible.

## Rollback Boundary

If visual preview breaks, task polling regresses, or legacy artifact rendering fails:

- revert the Phase 721 frontend patch immediately

- return to `e2097e91`

- do not patch worker or backend routes

- do not layer speculative frontend fixes past three failed attempts

## Immediate Next Step

Inspect current semantic detection insertion points and design the smallest UI-only enrichment patch.


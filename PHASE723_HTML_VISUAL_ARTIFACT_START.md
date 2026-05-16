
# Phase 723: HTML-Embedded Visual Artifact Rendering Corridor Start

## Objective

Begin Phase 723 as a strictly frontend-isolated corridor for HTML-embedded visual artifact rendering while preserving the current stable semantic artifact visibility baseline.

## Authoritative Baseline

- Stable semantic artifact visibility baseline: `76689dca`

- Current branch: `phase719-artifact-visibility`

- Docker runtime: authoritative

- Dashboard: stable

- Worker: stable

- Postgres: stable

- Retry architecture: preserved

- Artifact preview route: preserved

- Markdown fallback: authoritative

## Phase 723 Target

The next safe target is controlled visual artifact rendering inside the existing Preview surface.

This phase must not alter backend execution contracts, retry contracts, SSE behavior, database schema, artifact persistence format, or task lifecycle routing.

## Safe Corridor

Phase 723 must begin with inspection only.

Initial inspection targets:

1. Existing Preview modal renderer

2. Existing artifact preview fetch path

3. Current semantic artifact rendering function

4. Markdown fallback rendering path

5. Any sanitization utilities already present

6. Any prior quarantined iframe/srcdoc helpers for historical reference only

## Forbidden Mutations

Do not mutate:

- Worker artifact persistence contract

- `/api/tasks/create`

- `/api/tasks`

- `/api/delegate-task`

- Retry/requeue contract

- SSE event pipeline

- Database schema

- Artifact storage format

- Docker compose topology

- Existing markdown fallback behavior

## Required Preservation

The following must remain true after every Phase 723 change:

- Existing markdown artifacts still render

- Semantic preview cards still render

- Preview modal still opens

- Artifact preview route remains read-only

- Recent Tasks polling remains stable

- Agent Pool refresh persistence remains stable

- Retry controls remain operational

- Dashboard rebuild remains successful

- Docker dashboard, worker, and Postgres remain healthy

## First Implementation Hypothesis

The safest first implementation path is:

1. Add a sanitized HTML visual block renderer inside the existing frontend Preview modal.

2. Trigger it only when an artifact contains an explicit trusted visual block marker.

3. Preserve markdown fallback as the default path.

4. Keep the rendered HTML subset minimal.

5. Avoid iframe/srcdoc reactivation.

6. Browser-validate before expanding scope.

## Suggested Marker Contract

Use a clearly bounded visual block marker inside markdown artifacts:

<!-- visual-artifact:start -->

<div class="artifact-visual-card">

  ...

</div>

<!-- visual-artifact:end -->

This marker should initially be frontend-rendered only and should not require worker schema changes.

## Initial Validation Checklist

Before committing any functional renderer change:

- Dashboard rebuild passes

- Docker dashboard remains healthy

- Worker remains healthy

- Postgres remains healthy

- Preview modal opens

- Existing semantic artifacts render unchanged

- Markdown fallback still appears when no visual block exists

- Visual block renders only when explicitly marked

- No duplicate preview content regression

- No Agent Pool refresh regression

- No polling degradation

## Rollback Rule

If the visual rendering experiment causes instability, duplicate rendering, polling degradation, preview regression, Agent Pool refresh regression, or backend route instability, revert immediately to the stable semantic rendering baseline.

Do not layer speculative fixes beyond three failed attempts.

## Current Phase Status

Phase 723 started in inspection-first mode.

No runtime contract mutation authorized yet.


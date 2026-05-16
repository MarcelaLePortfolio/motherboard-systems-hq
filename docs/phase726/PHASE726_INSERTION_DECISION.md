
# Phase 726 Insertion Decision — Pre-Integration Gate

## Decision Status

Runtime integration remains blocked.

Phase 726 semantic helpers must stay inspect-only until the exact artifact generation and persistence hook is confirmed from source review.

## Current Evidence Captured

Evidence documents now available:

- docs/phase726/PHASE726_RUNTIME_DISCOVERY.md

- docs/phase726/PHASE726_RUNTIME_INSERTION_POINTS.md

- docs/phase726/PHASE726_RUNTIME_SOURCE_EXCERPTS.md

- docs/phase726/PHASE726_CHECKPOINT.md

## Confirmed Runtime Areas

Current discovery has identified the following runtime areas as relevant:

- artifact preview route:

  - server/routes/api-tasks-postgres.mjs

- frontend preview renderer:

  - public/js/phase530_visible_panels_bridge.js

- likely worker artifact/content generation candidates:

  - server/worker/response_compiler.mjs

  - server/worker/task_execution_interpreter.mjs

  - server/worker/execute_task_with_contract.mjs

  - server/artifacts.mjs

## Current Safe Conclusion

The frontend preview renderer and preview route are not the preferred first integration point.

Reason:

- the Phase 726 goal is worker-authored semantic intelligence

- frontend-only integration would preserve renderer-derived interpretation

- preview route mutation would risk read-only route stability

- artifact preview behavior is already stable and should not be disturbed first

## Preferred Future Integration Shape

Preferred future integration should occur in the worker-side artifact generation path, if and only if a clean insertion point is confirmed.

The safest future shape is:

1. worker produces existing artifact markdown exactly as before

2. Phase 726 helper composes semantic metadata beside the existing markdown

3. helper output is validated

4. validation failure silently falls back to existing behavior

5. persisted markdown and preview response remain backward compatible

## Blockers Before Integration

Do not integrate until these are answered:

1. Which function creates final artifact markdown?

2. Which function writes artifact metadata into completed task payload?

3. Is the completed task payload allowed to carry additive metadata without frontend breakage?

4. Can helper failure be fully isolated?

5. Can validation run without adding dependencies?

6. Can the semantic payload remain optional?

## Current Decision

Continue discovery.

Do not wire semantic helpers into runtime yet.


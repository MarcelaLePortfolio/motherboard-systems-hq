
# Phase 726 Runtime Discovery — Artifact Generation Path

## Purpose

This document captures the first read-only discovery step before any Phase 726 semantic helpers are wired into runtime execution.

The goal is to identify the existing artifact generation path and locate the smallest safe additive insertion point.

## Discovery Rules

- Do not mutate runtime execution.

- Do not mutate retry architecture.

- Do not mutate SSE payloads.

- Do not mutate task polling.

- Do not mutate database schema.

- Do not mutate artifact preview routes.

- Do not remove markdown fallback behavior.

- Do not integrate semantic helpers until the existing generation path is understood.

## Current Helper Status

The Phase 726 helper chain is currently inspect-only.

Validated helpers:

- worker/semantic/classifyArtifact.js

- worker/visual/generateVisualMetadata.js

- worker/semantic/composeSemanticArtifact.js

- worker/semantic/validateSemanticArtifact.js

- worker/semantic/inspectSemanticPipeline.js

Validation command:

npm run phase726:semantic:test

Current validation status:

Passing.

## Discovery Target

The next engineering task is to locate:

1. where worker task output is generated

2. where artifact markdown is created

3. where visual artifact blocks are inserted

4. where artifacts are persisted

5. where preview route reads artifact content

6. whether metadata can be added without changing persisted markdown or existing preview behavior

## Safe Candidate Integration Principle

Any future integration must be additive only.

Preferred future shape:

- existing markdown artifact remains unchanged

- semantic payload is generated beside existing output

- semantic payload is validated before use

- preview behavior remains backward compatible

- helper failure must fall back silently to existing behavior

## Integration Status

Not integrated.

No runtime code should depend on Phase 726 semantic helpers until this discovery document is updated with exact file paths and insertion points.


# Phase 15 — Project Visual Output → Real Artifacts Wiring

Baseline: v14.4-project-output-restored  
Objective: Replace placeholder Project Visual Output rendering with real task/build artifacts.

## Artifact Contract
All artifacts must be emitted by the server (no client synthesis).

{
  "type": "task_result | build_output | log",
  "source": "cade | matilda | effie",
  "taskId": "optional",
  "timestamp": "ISO-8601",
  "payload": {}
}

## Backend
- Add SSE endpoint: /events/artifacts
- Emit artifact on:
  - Task completion
  - Build completion
  - Explicit agent artifact publish
- Persist last artifact per task/build for refresh replay

## Frontend
- Subscribe Project Visual Output panel to /events/artifacts
- Render by type:
  - task_result → JSON viewer
  - build_output → status + hash + metadata
  - log → streaming log pane
- Fallback state: “No artifacts yet”

## Guardrails
- Only server-emitted artifacts
- No inferred or reconstructed output
- Must degrade gracefully if stream unavailable

## Acceptance
- Artifact appears ≤1s after task/build completes
- Refresh restores last artifact
- No console errors on idle


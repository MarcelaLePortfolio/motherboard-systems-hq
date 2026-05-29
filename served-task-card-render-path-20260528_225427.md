# Served Task Card Render Path Verification

Endpoint: http://localhost:8080

## Served JS Marker Check

- Preview marker: FOUND
- Inspect trace marker: FOUND
- Inspect logs marker: FOUND
- renderRecent marker: FOUND
- taskRows marker: FOUND
- artifactRaw payload support: FOUND
- trace payload support: FOUND

## API Target Row Check

Target row: FOUND
task_id: task-card-controls-visible-smoke
status: done
artifact payload: FOUND
trace payload: FOUND
logs payload: FOUND

## Expected Control Evaluation

Preview expected: YES
Inspect trace expected: YES
Inspect logs expected: YES

## Diagnosis

Served JS and API data both satisfy the control-rendering contract.
If the controls are not visible in the browser, the remaining issue is live DOM rendering, browser cache, filtering, or a different mounted task list surface.

## Target Row Sample

{
  "id": 11,
  "task_id": "task-card-controls-visible-smoke",
  "title": "Task card controls visible smoke",
  "status": "done",
  "notes": "Smoke row seeded to verify Preview, Inspect trace, and Inspect logs pills.",
  "run_id": "task-card-controls-visible-smoke",
  "action_tier": "A",
  "kind": "delegated",
  "payload": {
    "logs": [
      "seeded control visibility smoke task",
      "artifact payload present",
      "trace payload present",
      "logs payload present"
    ],
    "agent": "cade",
    "trace": {
      "phase": "task-card-control-smoke",
      "reason": "payload includes trace data for Inspect trace pill",
      "status": "done"
    },
    "source": "task_card_controls_smoke",
    "artifact": {
      "path": "ARTIFACTS/task-card-controls-smoke.md",
      "type": "markdown",
      "filename": "task-card-controls-smoke.md",
      "size_bytes": 512
    },
    "outcome_preview": "Task card control smoke completed.",
    "explanation_preview": "This row intentionally includes artifact, trace, and logs payloads so the task card controls can render."
  },
  "metadata": {},
  "created_at": "2026-05-29T05:47:50.915Z",
  "updated_at": "2026-05-29T05:47:50.915Z"
}

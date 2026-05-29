# Task Card Control Payload Visibility Verification

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
Branch: feature/backup-system-v2
HEAD: 8a55ea56900d7fb6aa3c99972ae7f8c6a2e9058f

## Verified Row

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

## Expected UI Result

- Preview pill should render because payload.artifact is present.
- Inspect trace should render because payload.trace is present.
- Inspect logs should render because payload.logs is present.

## Conclusion

The API payload shape matches what phase530_visible_panels_bridge.js expects.
If the controls are still not visible, the remaining issue is frontend rendering/filtering rather than missing task data.

Open: http://localhost:8080/?v=task-card-controls-visible-smoke

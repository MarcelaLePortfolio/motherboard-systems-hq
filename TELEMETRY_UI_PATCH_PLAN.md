Telemetry UI Patch Plan (Execution Step 1)

Objective:
Begin enforcement of telemetry scope separation by removing duplicated system metrics from Task History and standardizing UI layer boundaries.

──────────────────────────────

STEP 1 — Task History Cleanup
- Remove any embedded System Metrics or global health snapshots from Task History view
- Ensure Task History only renders:
  - task_id
  - state transitions (queued → running → completed → failed)
  - timestamps
  - retry/failure metadata

──────────────────────────────

STEP 2 — System Metrics Isolation
- Confirm System Metrics are only rendered in:
  - Top-level dashboard / system health panel
- Audit for accidental reuse in any child components

──────────────────────────────

STEP 3 — Telemetry Console Integrity
- Ensure Telemetry Console is strictly event-stream only
- Remove any grouped summary panels or aggregated “status cards”

──────────────────────────────

VALIDATION RULE
- No metric type may appear in more than one UI layer
- All metrics must have a single canonical rendering location

──────────────────────────────

STATUS
Phase: UI Enforcement Pass 1
Scope: Frontend only
Backend: No changes

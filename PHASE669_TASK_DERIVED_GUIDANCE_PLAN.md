# Phase 669 — Task-Derived Guidance Plan

Confirmed contract:
- Input: subsystems array
- Output: guidance array
- Severity: numeric
- Sorting: internal via sortByPriority()

Safe implementation corridor:
- Keep active route response shape unchanged.
- Convert task rows into engine-compatible subsystem records.
- Add synthetic subsystem records only when task data exists:
  - execution status degraded when failed/error tasks exist
  - queue status warning when queued tasks exist
  - retry status warning when attempts > 0 exists
- Do not add external output wrapper.
- Do not mutate execution, worker, scheduler, or DB schema.

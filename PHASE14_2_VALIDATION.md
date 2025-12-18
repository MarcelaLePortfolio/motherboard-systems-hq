# Phase 14.2 — Server-side validation & defensive writes

What this phase introduces:
- A single normalization function for tasks
- Explicit validation for:
  - new task creation
  - status transitions
- Server-controlled timestamps
- String-normalized IDs across DB / API / UI

Rules enforced:
- title + agent required
- status must be in enum
- terminal states cannot change
- no regression transitions allowed

Next integration steps (Phase 14.2 continuation):
- Import normalizeTask() in task create/update routes
- Validate transitions before DB writes
- Return consistent { ok, task } or { ok:false, error } payloads

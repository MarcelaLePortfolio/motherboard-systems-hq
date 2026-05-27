PHASE 62B — TASKS QUEUED
BLOCKER FINDINGS

DATE

2026-03-17

STATUS

IMPLEMENTATION BLOCKED UNDER CURRENT CORRIDOR RULES

SUMMARY

Discovery and server-surface inspection confirm that the current dashboard corridor does not expose an existing safe DOM hook for a new "Tasks Queued" metric tile, and the existing "Tasks Running" metric is hydrated inside the browser-side task-events corridor rather than from a shared server-side metrics object.

VERIFIED FINDINGS

1. `server.mjs` currently exposes:
   - `/api/tasks`
   - `/events/tasks`
   - raw task rows from `tasks`
   - no existing shared metric response object for running/completed/failed/queued

2. `Tasks Running` is currently derived inside the browser-side task-events binder.
   - Existing hook: `metric-running`
   - Existing logic tracks active task ids from task-events stream semantics

3. `queued` is a valid persisted task status in the repo.
   - Multiple claim scripts and SQL paths reference `status = 'queued'`

4. No existing safe queued metric DOM hook was confirmed in the current dashboard surface.
   - Adding one would require layout mutation
   - Layout mutation is outside the current corridor rules

CORRIDOR IMPLICATION

A safe "Tasks Queued" implementation is NOT currently available if all of the following must remain true:

- no layout mutation
- no transport mutation
- no reducer mutation
- no authority expansion

Therefore:

Proceeding directly to hydrate a visible queued metric would violate corridor discipline.

SAFE CONCLUSION

Do NOT implement Tasks Queued as the next bounded metric under the current rules.

RECOMMENDED NEXT ACTION

Select a next metric that can be hydrated through an already-existing display hook or existing derived corridor without layout change.

BEST CURRENT CANDIDATE

Continue bounded work only after selecting a metric that satisfies ALL of:

- existing DOM hook already present
- existing derivation corridor already present
- zero layout mutation
- zero transport mutation

DISCIPLINE NOTE

This is a valid stop.
Not every metric is corridor-safe at the current surface.
Protection rules remain higher priority than forward motion.

END

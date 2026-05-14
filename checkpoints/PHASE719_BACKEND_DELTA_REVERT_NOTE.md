
PHASE 719 BACKEND DELTA REVERT NOTE

Reason:

- server.js and server/routes/api-tasks-postgres.mjs showed a destructive rewrite:

  54 insertions, 991 deletions.

- Runtime health check showed:

  / returned placeholder only.

  /api/tasks returned Cannot GET /api/tasks.

- This is not a safe baseline for artifact UI work.

Action:

- Reverted only:

  server.js

  server/routes/api-tasks-postgres.mjs

Preserved:

- Unsafe diff saved at:

  checkpoints/PHASE719_UNSAFE_BACKEND_DELTA_REVERTED.patch

Next:

- Restore stable task API/dashboard behavior first.

- Only then proceed to UI artifact visibility wiring.


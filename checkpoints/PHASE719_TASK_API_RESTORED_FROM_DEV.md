
PHASE 719 TASK API RESTORED FROM DEV

Reason:

- Current branch runtime showed root placeholder only.

- Current branch runtime showed /api/tasks returning Cannot GET /api/tasks.

- Baseline comparison confirmed dev contains restored task API routing:

  app.use("/api/tasks", apiTasksRouter)

  express.static dashboard/public serving

  apiTasksRouter export shape

Action:

- Restored only:

  server.js

  server/routes/api-tasks-postgres.mjs

Source:

- dev

Next:

- Restart dashboard.

- Verify /api/tasks.

- Verify dashboard route.

- Then resume artifact UI work only after stable runtime confirmation.


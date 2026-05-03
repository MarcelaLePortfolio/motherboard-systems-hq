# Phase 626 API Tasks Handler Location

./server.js:33:app.use("/api/tasks", apiTasksRouter);
./server.js:59:    const forward = await fetch("http://localhost:3000/api/tasks/create", {
./server/api/tasks-mutations/delegate-taskspec.mjs:20: * POST /api/tasks-mutations/delegate-taskspec
./server/enforcement/phase44_mutation_allowlist.mjs:6: *   { method: "POST", path: "/api/tasks" }
./server/enforcement/phase44_mutation_allowlist.mjs:7: *   { method: "POST", path: "/api/tasks/:task_id/cancel" }
./server/enforcement/phase44_mutation_allowlist.mjs:14:  // { method: "POST", path: "/api/tasks" },
./server/enforcement/phase44_mutation_enforcer.mjs:26: * - "/api/tasks/:id/cancel" => /^\/api\/tasks\/[^/]+\/cancel$/
./server/enforcement/phase44_mutation_enforcer.mjs:27: * - "/api/tasks" => /^\/api\/tasks$/
./server/routes/api-tasks-postgres.mjs:38:// GET /api/tasks?limit=25  -> recent tasks for dashboard widget
./server/routes/api-tasks-postgres.mjs:40:  console.log("[phase57c-router] /api/tasks probe", {
./server/routes/api-tasks-postgres.mjs:82:    console.error("[phase25] /api/tasks list error", e);
./server/routes/api-tasks-postgres.mjs:87:// POST /api/tasks/create  { task_id?, title?, agent?, run_id?, ... }
./server/routes/api-tasks-postgres.mjs:93:    console.log("[phase25] /api/tasks/create pool snapshot", {
./server/routes/api-tasks-postgres.mjs:119:      INSERT INTO tasks (task_id, title, status, kind, payload, run_id, action_tier, notes)
./server/routes/api-tasks-postgres.mjs:125:          payload     = COALESCE(EXCLUDED.payload, tasks.payload),
./server/routes/api-tasks-postgres.mjs:160:    console.error("[phase25] /api/tasks error", e);
./server/routes/api-tasks-postgres.mjs:170:// POST /api/tasks/complete  { task_id, status?, run_id?, ... }
./server/routes/api-tasks-postgres.mjs:174:    assertNotEnforced("http:/api/tasks/create");
./server/routes/api-tasks-postgres.mjs:198:    console.error("[phase25] /api/tasks error", e);
./server/routes/api-tasks-postgres.mjs:208:// POST /api/tasks/fail  { task_id, error?, status?, run_id?, ... }
./server/routes/api-tasks-postgres.mjs:212:    assertNotEnforced("http:/api/tasks/complete");
./server/routes/api-tasks-postgres.mjs:236:    console.error("[phase25] /api/tasks error", e);
./server/routes/api-tasks-postgres.mjs:246:// POST /api/tasks/cancel  { task_id, run_id?, ... }
./server/routes/api-tasks-postgres.mjs:250:    assertNotEnforced("http:/api/tasks/cancel");
./server/routes/api-tasks-postgres.mjs:253:    assertNotEnforced("http:/api/tasks/fail");
./server/routes/api-tasks-postgres.mjs:276:    console.error("[phase25] /api/tasks error", e);
./public/js/dashboard-tasks-widget.js:10:    list: "/api/tasks",
./public/js/dashboard-tasks-widget.js:11:    complete: "/api/tasks/complete",
./public/js/phase487_humanize_task_ids.js:8:      const res = await fetch("/api/tasks?limit=50");
./public/js/phase487_humanize_task_ids.js:11:      const tasks = Array.isArray(payload?.tasks)
./public/js/phase530_visible_panels_bridge.js:176:      const data = await getJson("/api/tasks?limit=12");
./public/js/phase565_recent_tasks_wire.js:68:      const res = await fetch("/api/tasks", { cache: "no-store" });
./public/js/phase31_6_seed_task_button.js:14:    "/api/tasks",
./public/js/phase31_6_seed_task_button.js:15:    "/api/tasks-postgres",
./public/js/phase31_6_seed_task_button.js:16:    "/api/tasks/create",
./public/js/phase61_recent_history_wire.js:7:  const INSPECTOR_ENDPOINT = "/api/tasks?limit=12";
./scripts/phase19_patch_mount_tasks_mutations.mjs:27:  // Prefer mounting after existing /api/tasks router if present; else after last app.use(...)
./scripts/phase88_14_5_patch_server_mount_system_health.mjs:31:    throw new Error('Mount anchor app.use("/api/tasks-mutations", apiTasksMutationsRouter); not found in server.mjs');
./server.mjs:63:app.use('/api/tasks', apiTasksRouter);
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server.js:33:app.use("/api/tasks", apiTasksRouter);
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server.js:59:    const forward = await fetch("http://localhost:3000/api/tasks/create", {
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/api/tasks-mutations/delegate-taskspec.mjs:20: * POST /api/tasks-mutations/delegate-taskspec
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/enforcement/phase44_mutation_allowlist.mjs:6: *   { method: "POST", path: "/api/tasks" }
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/enforcement/phase44_mutation_allowlist.mjs:7: *   { method: "POST", path: "/api/tasks/:task_id/cancel" }
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/enforcement/phase44_mutation_allowlist.mjs:14:  // { method: "POST", path: "/api/tasks" },
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/enforcement/phase44_mutation_enforcer.mjs:26: * - "/api/tasks/:id/cancel" => /^\/api\/tasks\/[^/]+\/cancel$/
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/enforcement/phase44_mutation_enforcer.mjs:27: * - "/api/tasks" => /^\/api\/tasks$/
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:38:// GET /api/tasks?limit=25  -> recent tasks for dashboard widget
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:40:  console.log("[phase57c-router] /api/tasks probe", {
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:66:    console.error("[phase25] /api/tasks list error", e);
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:71:// POST /api/tasks/create  { task_id?, title?, agent?, run_id?, ... }
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:77:    console.log("[phase25] /api/tasks/create pool snapshot", {
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:103:      INSERT INTO tasks (task_id, title, status, kind, payload, run_id, action_tier, notes)
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:109:          payload     = COALESCE(EXCLUDED.payload, tasks.payload),
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:144:    console.error("[phase25] /api/tasks error", e);
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:154:// POST /api/tasks/complete  { task_id, status?, run_id?, ... }
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:158:    assertNotEnforced("http:/api/tasks/create");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:182:    console.error("[phase25] /api/tasks error", e);
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:192:// POST /api/tasks/fail  { task_id, error?, status?, run_id?, ... }
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:196:    assertNotEnforced("http:/api/tasks/complete");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:220:    console.error("[phase25] /api/tasks error", e);
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:230:// POST /api/tasks/cancel  { task_id, run_id?, ... }
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:234:    assertNotEnforced("http:/api/tasks/cancel");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:237:    assertNotEnforced("http:/api/tasks/fail");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/routes/api-tasks-postgres.mjs:260:    console.error("[phase25] /api/tasks error", e);
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/dashboard-tasks-widget.js:10:    list: "/api/tasks",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/dashboard-tasks-widget.js:11:    complete: "/api/tasks/complete",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase487_humanize_task_ids.js:8:      const res = await fetch("/api/tasks?limit=50");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase487_humanize_task_ids.js:11:      const tasks = Array.isArray(payload?.tasks)
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase530_visible_panels_bridge.js:176:      const data = await getJson("/api/tasks?limit=12");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase565_recent_tasks_wire.js:68:      const res = await fetch("/api/tasks", { cache: "no-store" });
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase31_6_seed_task_button.js:14:    "/api/tasks",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase31_6_seed_task_button.js:15:    "/api/tasks-postgres",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase31_6_seed_task_button.js:16:    "/api/tasks/create",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase61_recent_history_wire.js:7:  const INSPECTOR_ENDPOINT = "/api/tasks?limit=12";
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/scripts/phase19_patch_mount_tasks_mutations.mjs:27:  // Prefer mounting after existing /api/tasks router if present; else after last app.use(...)
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/scripts/phase88_14_5_patch_server_mount_system_health.mjs:31:    throw new Error('Mount anchor app.use("/api/tasks-mutations", apiTasksMutationsRouter); not found in server.mjs');
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server.mjs:63:app.use('/api/tasks', apiTasksRouter);
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server.js:33:app.use("/api/tasks", apiTasksRouter);
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server.js:59:    const forward = await fetch("http://localhost:3000/api/tasks/create", {
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/api/tasks-mutations/delegate-taskspec.mjs:20: * POST /api/tasks-mutations/delegate-taskspec
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/enforcement/phase44_mutation_allowlist.mjs:6: *   { method: "POST", path: "/api/tasks" }
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/enforcement/phase44_mutation_allowlist.mjs:7: *   { method: "POST", path: "/api/tasks/:task_id/cancel" }
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/enforcement/phase44_mutation_allowlist.mjs:14:  // { method: "POST", path: "/api/tasks" },
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/enforcement/phase44_mutation_enforcer.mjs:26: * - "/api/tasks/:id/cancel" => /^\/api\/tasks\/[^/]+\/cancel$/
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/enforcement/phase44_mutation_enforcer.mjs:27: * - "/api/tasks" => /^\/api\/tasks$/
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:38:// GET /api/tasks?limit=25  -> recent tasks for dashboard widget
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:40:  console.log("[phase57c-router] /api/tasks probe", {
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:82:    console.error("[phase25] /api/tasks list error", e);
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:87:// POST /api/tasks/create  { task_id?, title?, agent?, run_id?, ... }
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:93:    console.log("[phase25] /api/tasks/create pool snapshot", {
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:119:      INSERT INTO tasks (task_id, title, status, kind, payload, run_id, action_tier, notes)
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:125:          payload     = COALESCE(EXCLUDED.payload, tasks.payload),
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:160:    console.error("[phase25] /api/tasks error", e);
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:170:// POST /api/tasks/complete  { task_id, status?, run_id?, ... }
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:174:    assertNotEnforced("http:/api/tasks/create");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:198:    console.error("[phase25] /api/tasks error", e);
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:208:// POST /api/tasks/fail  { task_id, error?, status?, run_id?, ... }
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:212:    assertNotEnforced("http:/api/tasks/complete");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:236:    console.error("[phase25] /api/tasks error", e);
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:246:// POST /api/tasks/cancel  { task_id, run_id?, ... }
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:250:    assertNotEnforced("http:/api/tasks/cancel");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:253:    assertNotEnforced("http:/api/tasks/fail");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/routes/api-tasks-postgres.mjs:276:    console.error("[phase25] /api/tasks error", e);
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/dashboard-tasks-widget.js:10:    list: "/api/tasks",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/dashboard-tasks-widget.js:11:    complete: "/api/tasks/complete",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase487_humanize_task_ids.js:8:      const res = await fetch("/api/tasks?limit=50");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase487_humanize_task_ids.js:11:      const tasks = Array.isArray(payload?.tasks)
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase530_visible_panels_bridge.js:176:      const data = await getJson("/api/tasks?limit=12");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase565_recent_tasks_wire.js:68:      const res = await fetch("/api/tasks", { cache: "no-store" });
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase31_6_seed_task_button.js:14:    "/api/tasks",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase31_6_seed_task_button.js:15:    "/api/tasks-postgres",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase31_6_seed_task_button.js:16:    "/api/tasks/create",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase61_recent_history_wire.js:7:  const INSPECTOR_ENDPOINT = "/api/tasks?limit=12";
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/scripts/phase19_patch_mount_tasks_mutations.mjs:27:  // Prefer mounting after existing /api/tasks router if present; else after last app.use(...)
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/scripts/phase88_14_5_patch_server_mount_system_health.mjs:31:    throw new Error('Mount anchor app.use("/api/tasks-mutations", apiTasksMutationsRouter); not found in server.mjs');
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server.mjs:63:app.use('/api/tasks', apiTasksRouter);

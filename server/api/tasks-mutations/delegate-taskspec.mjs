/**
 * Phase 23: TaskSpec adapter
 * POST /api/tasks-mutations/delegate-taskspec
 *
 * Accepts:
 * - { task: { target:"cade"|"effie"|"atlas", title?, spec?, task_id? } }
 * - { task: { agent:"cade"|"effie"|"atlas",  title?, spec?, task_id? } }  (alias)
 *
 * Behavior:
 * - Calls dbDelegateTask(...) to create the task (existing system)
 * - Inserts into task_events(kind="task.created") so /events/task-events advances
 */
export async function handleDelegateTaskSpec(req, res, deps) {
  try {
    const body = req.body ?? {};
    const taskSpec = body.task ?? body;

    const rawTarget = taskSpec?.target ?? taskSpec?.agent ?? "";
    const target = String(rawTarget).trim().toLowerCase();

    if (!["cade", "effie", "atlas"].includes(target)) {
      return res.status(400).json({
        ok: false,
        error: "invalid_target",
        details: "target must be cade|effie|atlas",
        got: String(rawTarget),
      });
    }

    const title = String(taskSpec?.title || "(untitled)");
    const spec = taskSpec?.spec ?? null;
    const external_task_id = taskSpec?.task_id ?? null;

    const db = deps?.db;
    const dbDelegateTask = deps?.dbDelegateTask;

    if (!db?.query) return res.status(500).json({ ok: false, error: "missing_db", details: "db pool not available" });
    if (typeof dbDelegateTask !== "function") {
      return res.status(500).json({ ok: false, error: "missing_dbDelegateTask", details: "dbDelegateTask not available" });
    }

    // Create task using existing db mutation
    const created = await dbDelegateTask(db, {
      agent: target,
      title,
      notes: "",
      source: "matilda",
      meta: { taskspec: spec, external_task_id },
    });

    const task = created?.task ?? created;
    const task_id = task?.id ?? null;
    return res.status(200).json({ ok: true, task });
  } catch (err) {
    return res.status(500).json({ ok: false, error: "delegate_taskspec_failed", details: String(err?.message || err) });
  }
}

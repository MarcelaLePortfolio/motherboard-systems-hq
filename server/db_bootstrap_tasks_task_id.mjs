export async function ensureTasksTaskIdColumn(db = globalThis.__DB_POOL) {
  if (!db || typeof db.query !== "function") {
    console.warn("[db_bootstrap_tasks_task_id] skipped: no query-capable db handle available");
    return { ok: false, skipped: true, reason: "missing_db_handle" };
  }

  await db.query(`
    ALTER TABLE public.tasks
    ADD COLUMN IF NOT EXISTS task_id TEXT
  `);

  return { ok: true };
}

export async function ensureTasksRunIdColumn(pool) {
  if (!pool || typeof pool.query !== "function") {
    throw new Error("ensureTasksRunIdColumn requires a pg pool with query()");
  }

  await pool.query(`
    alter table tasks
    add column if not exists run_id text
  `);

  await pool.query(`
    create index if not exists idx_tasks_run_id
    on tasks (run_id)
  `);
}

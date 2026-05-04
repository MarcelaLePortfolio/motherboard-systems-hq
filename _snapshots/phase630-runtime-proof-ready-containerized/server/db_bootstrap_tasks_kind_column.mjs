export async function ensureTasksKindColumn(pool) {
  if (!pool || typeof pool.query !== "function") {
    throw new Error("ensureTasksKindColumn requires a pg pool with query()");
  }

  await pool.query(`
    alter table tasks
    add column if not exists kind text
  `);

  await pool.query(`
    create index if not exists idx_tasks_kind
    on tasks (kind)
  `);
}

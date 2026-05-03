export async function ensureTasksActionTierColumn(pool) {
  if (!pool || typeof pool.query !== "function") {
    throw new Error("ensureTasksActionTierColumn requires a pg pool with query()");
  }

  await pool.query(`
    alter table tasks
    add column if not exists action_tier text
  `);

  await pool.query(`
    create index if not exists idx_tasks_action_tier
    on tasks (action_tier)
  `);
}

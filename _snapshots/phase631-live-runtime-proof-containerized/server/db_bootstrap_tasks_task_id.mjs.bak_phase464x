export async function ensureTasksTaskIdColumn(pool) {
  // Idempotent, safe for dev: makes string task_id support durable.
  await pool.query(`alter table tasks add column if not exists task_id text;`);
  await pool.query(`create index if not exists tasks_task_id_idx on tasks(task_id);`);
}

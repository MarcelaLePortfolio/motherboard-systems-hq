export async function ensureTasksTaskIdColumn(pool) {
  // Idempotent bootstrap: ensure tasks exists, then ensure task_id + index.
  // CI can start from a blank PG volume; this prevents dashboard crash on boot.

  await pool.query(`
    CREATE TABLE IF NOT EXISTS public.tasks (
      id bigserial PRIMARY KEY,
      task_id text,
      status text,
      kind text,
      payload jsonb,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );
  `);

  // Ensure the column exists even if an older schema created tasks without it.
  await pool.query(`ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS task_id text;`);

  // Index is harmless if task_id is NULL for older rows.
  await pool.query(`CREATE INDEX IF NOT EXISTS tasks_task_id_idx ON public.tasks(task_id);`);
}

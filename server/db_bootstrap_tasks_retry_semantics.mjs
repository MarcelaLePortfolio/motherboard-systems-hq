/**
 * Phase 27 — Tasks table retry + lease semantics (Postgres bootstrap)
 * Safe to run on every boot (ADD COLUMN IF NOT EXISTS).
 */
export async function bootstrapTasksRetrySemantics(pool) {
  if (!pool) throw new Error("bootstrapTasksRetrySemantics: pool required");

  // attempt / max_attempts
  await pool.query(`alter table tasks add column if not exists attempt int not null default 0;`);
  await pool.query(`alter table tasks add column if not exists max_attempts int not null default 5;`);

  // availability gate + lease fields
  await pool.query(`alter table tasks add column if not exists available_at timestamptz null;`);
  await pool.query(`alter table tasks add column if not exists locked_by text null;`);
  await pool.query(`alter table tasks add column if not exists lock_expires_at timestamptz null;`);

  // last_error payload
  await pool.query(`alter table tasks add column if not exists last_error jsonb null;`);

  // helpful indexes for claim loop
  await pool.query(`create index if not exists tasks_status_available_idx on tasks(status, available_at);`);
  await pool.query(`create index if not exists tasks_lock_expires_idx on tasks(lock_expires_at);`);
}

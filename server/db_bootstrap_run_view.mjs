export async function ensureRunView(pool) {
  if (!pool || typeof pool.query !== "function") {
    throw new Error("ensureRunView requires a pg pool with query()");
  }

  await pool.query(`
    create or replace view run_view as
    select
      t.id::text as id,
      t.task_id::text as task_id,
      t.run_id::text as run_id,
      t.status::text as status,
      t.updated_at as updated_at,
      t.created_at as created_at,
      coalesce(
        t.payload->>'agent',
        t.payload->>'owner',
        t.payload->>'actor',
        'unassigned'
      )::text as agent
    from tasks t
  `);
}

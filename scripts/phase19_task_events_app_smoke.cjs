/**
 * Phase 19: app-level Postgres write -> read smoke test for public.task_events
 *
 * Usage:
 *   eval "$(scripts/phase19_export_postgres_env.sh)"
 *   node scripts/phase19_task_events_app_smoke.cjs
 */
const pg = require("pg");

const url =
  process.env.DATABASE_URL ||
  process.env.POSTGRES_URL ||
  process.env.POSTGRES_URI ||
  process.env.POSTGRES_CONNECTION_STRING;

if (!url) {
  console.error("Missing DATABASE_URL/POSTGRES_URL env var.");
  process.exit(2);
}

(async () => {
  const client = new pg.Client({ connectionString: url });
  try {
    await client.connect();

    const reg = await client.query("select to_regclass('public.task_events') as reg;");
    if (!reg.rows?.[0]?.reg) {
      console.error("Table public.task_events not found.");
      process.exit(2);
    }

    const payloadObj = {
      ok: true,
      step: "app_write_read",
      ts: Date.now(),
      note: "phase19 app-level smoke",
    };

    const ins = await client.query(
      "insert into public.task_events (kind, payload) values ($1, $2) returning *;",
      ["app-smoke", JSON.stringify(payloadObj)]
    );

    const inserted = ins.rows?.[0] || null;

    const latest = await client.query(
      "select id, kind, payload, created_at from public.task_events order by id desc limit 5;"
    );

    console.log(
      JSON.stringify(
        { ok: true, inserted, latest: latest.rows },
        null,
        2
      )
    );

    await client.end();
  } catch (e) {
    console.error("APP_SMOKE_FAILED:", e && e.stack ? e.stack : e);
    try { await client.end(); } catch {}
    process.exit(2);
  }
})();

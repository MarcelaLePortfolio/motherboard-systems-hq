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

    const ins = await client.query(
      "insert into public.task_events (kind, payload) values ($1, $2) returning *;",
      ["smoke", JSON.stringify({ smoke: true, ts: Date.now() })]
    );

    const inserted = ins.rows?.[0] || null;
    const sel = await client.query("select count(*)::bigint as count from public.task_events;");
    const count = sel.rows?.[0]?.count;

    console.log(JSON.stringify({ ok: true, inserted, totalCount: count }, null, 2));
    await client.end();
  } catch (e) {
    console.error("Smoke test failed:", e && e.stack ? e.stack : e);
    try { await client.end(); } catch {}
    process.exit(2);
  }
})();

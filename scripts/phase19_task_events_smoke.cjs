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

const { Client } = pg;

function valueExprFor(col) {
  const udt = (col.udt_name || "").toLowerCase();
  const dt = (col.data_type || "").toLowerCase();

  if (udt === "uuid") return "gen_random_uuid()";
  if (udt === "jsonb") return `'{"smoke":true}'::jsonb`;
  if (udt === "json") return `'{"smoke":true}'::json`;
  if (dt.includes("timestamp")) return "now()";
  if (udt === "date") return "current_date";
  if (udt === "time") return "current_time";
  if (udt === "text" || udt === "varchar" || udt === "bpchar") return `'smoke'`;
  if (udt === "bool") return "true";
  if (udt === "int2" || udt === "int4" || udt === "int8" || udt === "numeric" || udt === "float4" || udt === "float8") return "0";
  if (udt === "timestamptz") return "now()";

  return null;
}

(async () => {
  const client = new Client({ connectionString: url });
  try {
    await client.connect();

    const reg = await client.query("select to_regclass('public.task_events') as reg;");
    if (!reg.rows?.[0]?.reg) {
      console.error("Table public.task_events not found. Run migrations/doctor output steps first.");
      process.exit(2);
    }

    const colsRes = await client.query(`
      select column_name, is_nullable, column_default, data_type, udt_name
      from information_schema.columns
      where table_schema='public' and table_name='task_events'
      order by ordinal_position;
    `);

    const cols = colsRes.rows;

    const required = cols.filter(
      (c) =>
        String(c.is_nullable).toUpperCase() === "NO" &&
        (c.column_default == null || String(c.column_default).trim() === "")
    );

    const assignments = [];
    const unknownRequired = [];

    for (const c of required) {
      const expr = valueExprFor(c);
      if (!expr) unknownRequired.push({ column_name: c.column_name, data_type: c.data_type, udt_name: c.udt_name });
      else assignments.push([c.column_name, expr]);
    }

    if (unknownRequired.length) {
      console.error("Cannot auto-fill required columns with unknown types:");
      for (const u of unknownRequired) console.error(`- ${u.column_name}: ${u.data_type} (${u.udt_name})`);
      process.exit(2);
    }

    const colNames = assignments.map(([n]) => `"${n}"`).join(", ");
    const values = assignments.map(([, v]) => v).join(", ");

    const insertSQL = assignments.length
      ? `insert into public.task_events (${colNames}) values (${values}) returning *;`
      : `insert into public.task_events default values returning *;`;

    const ins = await client.query(insertSQL);
    const inserted = ins.rows?.[0] || null;

    const sel = await client.query("select count(*)::bigint as count from public.task_events;");
    const count = sel.rows?.[0]?.count;

    console.log(JSON.stringify({ ok: true, inserted, totalCount: count }, null, 2));
    await client.end();
  } catch (e) {
    console.error("Smoke test failed:", e && e.message ? e.message : e);
    try { await client.end(); } catch {}
    process.exit(2);
  }
})();

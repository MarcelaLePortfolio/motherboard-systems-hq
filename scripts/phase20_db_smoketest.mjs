import pg from "pg";

const { Pool } = pg;

const DB_URL_RAW = process.env.POSTGRES_URL || process.env.DATABASE_URL || "";
function _normalizeDbUrl(raw) {
  try {
    if (!raw) return "";
    if (!/^postgres(ql)?:\/\//i.test(raw)) return raw;
    const u = new URL(raw);
    const hasUser = (u.username || "") !== "";
    const hasPw = (u.password || "") !== "";
    if (hasUser && !hasPw) u.password = String(process.env.PGPASSWORD || "postgres");
    return u.toString();
  } catch (_) {
    return raw;
  }
}
const DB_URL = _normalizeDbUrl(DB_URL_RAW);

const cfg = DB_URL
  ? { connectionString: DB_URL }
  : {
      host: process.env.PGHOST || "postgres",
      port: Number(process.env.PGPORT || 5432),
      user: process.env.PGUSER || "postgres",
      password: String(process.env.PGPASSWORD || "postgres"),
      database: process.env.PGDATABASE || "postgres",
    };

console.log("[smoke] using", DB_URL ? { mode: "url", hasPw: /\/\/[^:]+:[^@]*@/.test(DB_URL) } : { mode: "params", ...{ host: cfg.host, port: cfg.port, user: cfg.user, database: cfg.database, passwordType: typeof cfg.password, passwordLen: String(cfg.password||"").length } });

const pool = new Pool(cfg);
try {
  const r = await pool.query("select 1 as ok");
  console.log("[smoke] ok:", r.rows?.[0]);
} catch (e) {
  console.error("[smoke] FAIL:", e?.message || String(e));
  process.exitCode = 1;
} finally {
  try { await pool.end(); } catch (_) {}
}

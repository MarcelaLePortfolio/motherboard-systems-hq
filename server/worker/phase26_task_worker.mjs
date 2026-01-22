/**
 * phase26_task_worker.mjs
 *
 * Instrumented worker runner with force-flush logging + explicit loop telemetry.
 * SQL param-count aware execution (auto-matches args to max $N referenced).
 */

import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";
import { setTimeout as sleep } from "node:timers/promises";
import pg from "pg";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function ms() { return Date.now(); }

const FORCE_FLUSH = String(process.env.WORKER_LOG_FLUSH || "").trim() === "1";

function safeFsync(fd) {
  if (!FORCE_FLUSH) return;
  try { fs.fsyncSync(fd); } catch {}
}

function log(obj) {
  process.stdout.write(JSON.stringify({ ts: ms(), ...obj }) + "\n");
  safeFsync(1);
}
function warn(obj) {
  process.stderr.write(JSON.stringify({ ts: ms(), level: "warn", ...obj }) + "\n");
  safeFsync(2);
}
function err(obj) {
  process.stderr.write(JSON.stringify({ ts: ms(), level: "error", ...obj }) + "\n");
  safeFsync(2);
}

function mustEnv(name) {
  const v = process.env[name];
  if (!v || !String(v).trim()) throw new Error(`missing_env:${name}`);
  return String(v);
}

function readSqlFile(sqlPath) {
  const resolved = path.isAbsolute(sqlPath) ? sqlPath : path.resolve(process.cwd(), sqlPath);
  const txt = fs.readFileSync(resolved, "utf-8");
  return { resolved, sql: txt.trim() };
}

function hasDollarParams(sql) {
  return /\$\d+/.test(String(sql || ""));
}

function maxDollarParam(sql) {
  const s = String(sql || "");
  let m;
  let max = 0;
  const re = /\$(\d+)/g;
  while ((m = re.exec(s)) !== null) {
    const n = Number(m[1]);
    if (Number.isFinite(n) && n > max) max = n;
  }
  return max;
}

function redactPg(url) {
  try {
    const u = new URL(url);
    if (u.password) u.password = "****";
    return u.toString();
  } catch {
    return String(url).replace(/:\/\/([^:]+):([^@]+)@/g, "://$1:****@");
  }
}

async function execSql(pool, sqlText, args) {
  const want = maxDollarParam(sqlText);
  if (want <= 0) return pool.query(sqlText);
  const a = (args || []).slice(0, want);
  if (a.length !== want) {
    throw new Error(`sql_param_arity_mismatch: want=${want} got=${a.length}`);
  }
  return pool.query(sqlText, a);
}

async function main() {
  const actor = process.env.PHASE26_WORKER_ACTOR || "phase26.worker";
  const owner = process.env.WORKER_OWNER || `worker-${process.pid}`;

  const tickMs = Number(process.env.PHASE26_TICK_MS || "500");
  const logEveryMs = Number(process.env.WORKER_LOG_EVERY_MS || "2500");
  const dbPingEveryMs = Number(process.env.WORKER_DB_PING_EVERY_MS || "30000");
  const once = String(process.env.WORKER_ONCE || "").trim() === "1";
  const exitOnDbErr = String(process.env.WORKER_EXIT_ON_DB_ERROR || "1").trim() === "1";

  const postgresUrl = mustEnv("POSTGRES_URL");

  const claimSqlPath = mustEnv("PHASE27_CLAIM_ONE_SQL");
  const markSuccessPath = process.env.PHASE27_MARK_SUCCESS_SQL || "";
  const markFailurePath = process.env.PHASE27_MARK_FAILURE_SQL || "";

  const claimSqlFile = readSqlFile(claimSqlPath);
  const markSuccessFile = markSuccessPath ? readSqlFile(markSuccessPath) : null;
  const markFailureFile = markFailurePath ? readSqlFile(markFailurePath) : null;

  log({
    kind: "worker.boot",
    file: __filename,
    cwd: process.cwd(),
    actor,
    owner,
    pid: process.pid,
    node: process.version,
    tickMs,
    logEveryMs,
    dbPingEveryMs,
    once,
    FORCE_FLUSH,
    POSTGRES_URL: redactPg(postgresUrl),
    PHASE27_CLAIM_ONE_SQL: claimSqlFile.resolved,
    PHASE27_MARK_SUCCESS_SQL: markSuccessFile ? markSuccessFile.resolved : null,
    PHASE27_MARK_FAILURE_SQL: markFailureFile ? markFailureFile.resolved : null,
    claimNeedsParams: hasDollarParams(claimSqlFile.sql),
    claimParamMax: maxDollarParam(claimSqlFile.sql),
    markSuccessNeedsParams: markSuccessFile ? hasDollarParams(markSuccessFile.sql) : null,
    markSuccessParamMax: markSuccessFile ? maxDollarParam(markSuccessFile.sql) : null,
    markFailureNeedsParams: markFailureFile ? hasDollarParams(markFailureFile.sql) : null,
    markFailureParamMax: markFailureFile ? maxDollarParam(markFailureFile.sql) : null,
  });

  process.on("uncaughtException", (e) => {
    err({ kind: "worker.uncaughtException", message: e?.message, stack: e?.stack });
    process.exitCode = 1;
  });
  process.on("unhandledRejection", (e) => {
    err({ kind: "worker.unhandledRejection", message: e?.message || String(e), stack: e?.stack });
    process.exitCode = 1;
  });
  process.on("exit", (code) => {
    log({ kind: "worker.exit", code });
  });
  process.on("SIGTERM", () => {
    warn({ kind: "worker.signal", signal: "SIGTERM" });
    process.exit(0);
  });
  process.on("SIGINT", () => {
    warn({ kind: "worker.signal", signal: "SIGINT" });
    process.exit(0);
  });

  const { Pool } = pg;
  const pool = new Pool({
    connectionString: postgresUrl,
    max: 4,
    idleTimeoutMillis: 30_000,
    connectionTimeoutMillis: 10_000,
  });

  try {
    const r = await pool.query("select 1 as ok");
    log({ kind: "worker.db_ok", row: r?.rows?.[0] || null });
  } catch (e) {
    err({ kind: "worker.db_error", message: e?.message, stack: e?.stack });
    await pool.end().catch(() => {});
    process.exit(1);
  }

  let lastAlive = 0;
  let lastDbPing = 0;
  let loops = 0;
  let claims = 0;
  let idles = 0;

  while (true) {
    const now = ms();
    loops++;

    if (now - lastAlive >= logEveryMs) {
      lastAlive = now;
      log({ kind: "worker.alive", loops, claims, idles, tickMs });
    }

    if (now - lastDbPing >= dbPingEveryMs) {
      lastDbPing = now;
      try {
        const r = await pool.query("select 1 as ok");
        log({ kind: "worker.db_ping_ok", row: r?.rows?.[0] || null });
      } catch (e) {
        err({ kind: "worker.db_ping_error", message: e?.message, stack: e?.stack });
        if (exitOnDbErr) {
          await pool.end().catch(() => {});
          process.exit(1);
        }
      }
    }

    let claimedRow = null;
    try {
      const run_id = `run-${now}-${owner}`;
      const res = await execSql(pool, claimSqlFile.sql, [run_id, owner]);
      claimedRow = res?.rows?.[0] || null;
    } catch (e) {
      err({
        kind: "worker.claim_error",
        message: e?.message,
        stack: e?.stack,
        hint: "Claim SQL param arity is auto-matched to max $N; if this still errors, SQL/schema mismatch remains.",
      });
      await sleep(Math.min(2000, Math.max(250, tickMs)));
      if (once) break;
      continue;
    }

    if (!claimedRow) {
      idles++;
      if (once) break;
      await sleep(Math.max(50, tickMs));
      continue;
    }

    claims++;
    log({ kind: "worker.claimed", claimed: claimedRow, claimed_keys: Object.keys(claimedRow || {}) });

    if (markSuccessFile) {
      try {
        const task_id = claimedRow.task_id ?? claimedRow.id ?? claimedRow.taskId ?? null;
        const run_id = claimedRow.run_id ?? claimedRow.runId ?? null;
        await execSql(pool, markSuccessFile.sql, [task_id, run_id, owner, actor, ms()]);
        log({ kind: "worker.mark_success_ok", task_id, run_id });
      } catch (e) {
        err({ kind: "worker.mark_success_error", message: e?.message, stack: e?.stack });
        if (markFailureFile) {
          try {
            const task_id = claimedRow.task_id ?? claimedRow.id ?? claimedRow.taskId ?? null;
            const run_id = claimedRow.run_id ?? claimedRow.runId ?? null;
            const reason = e?.message || "mark_success_failed";
            await execSql(pool, markFailureFile.sql, [task_id, run_id, owner, actor, ms(), reason]);
            log({ kind: "worker.mark_failure_ok", task_id, run_id, reason });
          } catch (e2) {
            err({ kind: "worker.mark_failure_error", message: e2?.message, stack: e2?.stack });
          }
        }
      }
    }

    if (once) break;
    await sleep(Math.max(25, tickMs));
  }

  log({ kind: "worker.done", once, loops, claims, idles });
  await pool.end().catch(() => {});
}

main().catch((e) => {
  err({ kind: "worker.fatal", message: e?.message, stack: e?.stack });
  process.exit(1);
});

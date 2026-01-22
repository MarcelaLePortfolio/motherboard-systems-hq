/**

phase26_task_worker.mjs

Instrumented worker runner with force-flush logging + explicit loop telemetry.

Goal: make it impossible for the worker to "silently idle/exit" while tasks remain queued.

Environment (existing):

POSTGRES_URL (required)

PHASE26_TICK_MS (default 500)

PHASE26_WORKER_ACTOR (default "phase26.worker")

WORKER_OWNER (default "worker-<pid>")

SQL file envs (existing names used by docker compose / later phases):

PHASE27_CLAIM_ONE_SQL (required)

PHASE27_MARK_SUCCESS_SQL (optional)

PHASE27_MARK_FAILURE_SQL (optional)

Extra debug envs (new but optional):

WORKER_LOG_FLUSH=1 (force best-effort fsync on stdout/stderr)

WORKER_LOG_EVERY_MS=2500 (periodic "alive" line even when idle)

WORKER_DB_PING_EVERY_MS=30000 (periodic SELECT 1)

WORKER_ONCE=1 (run one claim attempt then exit 0)

WORKER_EXIT_ON_DB_ERROR=1 (default 1) exit if DB ping fails
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

function safeFsyncStdout() {
if (!FORCE_FLUSH) return;
try {
// Best-effort: may throw on some platforms/runtimes; ignore.
fs.fsyncSync(1);
} catch {}
}

function safeFsyncStderr() {
if (!FORCE_FLUSH) return;
try {
fs.fsyncSync(2);
} catch {}
}

function log(obj) {
const line = JSON.stringify({ ts: ms(), ...obj });
process.stdout.write(line + "\n");
safeFsyncStdout();
}

function warn(obj) {
const line = JSON.stringify({ ts: ms(), level: "warn", ...obj });
process.stderr.write(line + "\n");
safeFsyncStderr();
}

function err(obj) {
const line = JSON.stringify({ ts: ms(), level: "error", ...obj });
process.stderr.write(line + "\n");
safeFsyncStderr();
}

function mustEnv(name) {
const v = process.env[name];
if (!v || !String(v).trim()) throw new Error(missing_env:${name});
return String(v);
}

function readSqlFile(sqlPath) {
const resolved = path.isAbsolute(sqlPath) ? sqlPath : path.resolve(process.cwd(), sqlPath);
const txt = fs.readFileSync(resolved, "utf-8");
// Normalize; keep as-is otherwise.
return { resolved, sql: txt.trim() };
}

function hasDollarParams(sql) {
return /$\d+/.test(String(sql || ""));
}

function redactPg(url) {
try {
const u = new URL(url);
if (u.password) u.password = "";
return u.toString();
} catch {
// If it's not a URL-parsable string, return minimal redaction.
return String(url).replace(/://([^:]+):([^@]+)@/g, "://$1:@");
}
}

async function main() {
const actor = process.env.PHASE26_WORKER_ACTOR || "phase26.worker";
const owner = process.env.WORKER_OWNER || worker-${process.pid};

const tickMs = Number(process.env.PHASE26_TICK_MS || "500");
const logEveryMs = Number(process.env.WORKER_LOG_EVERY_MS || "2500");
const dbPingEveryMs = Number(process.env.WORKER_DB_PING_EVERY_MS || "30000");
const once = String(process.env.WORKER_ONCE || "").trim() === "1";
const exitOnDbErr = String(process.env.WORKER_EXIT_ON_DB_ERROR || "1").trim() === "1";

const postgresUrl = mustEnv("POSTGRES_URL");

// SQL envs
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
markSuccessNeedsParams: markSuccessFile ? hasDollarParams(markSuccessFile.sql) : null,
markFailureNeedsParams: markFailureFile ? hasDollarParams(markFailureFile.sql) : null,
});

// Hard fail on silent errors.
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

// Confirm DB OK up front.
try {
const r = await pool.query("select 1 as ok");
log({ kind: "worker.db_ok", row: r?.rows?.[0] || null });
} catch (e) {
err({ kind: "worker.db_error", message: e?.message, stack: e?.stack });
await pool.end().catch(() => {});
process.exit(1);
}

// Periodic "alive" telemetry regardless of work.
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
  // Prefer safe param usage if SQL expects $1/$2/$3...:
  // Convention we use: $1=owner, $2=actor, $3=ts_ms
  if (hasDollarParams(claimSqlFile.sql)) {
    const res = await pool.query(claimSqlFile.sql, [owner, actor, now]);
    claimedRow = res?.rows?.[0] || null;
  } else {
    // If SQL has no params, just execute.
    const res = await pool.query(claimSqlFile.sql);
    claimedRow = res?.rows?.[0] || null;
  }
} catch (e) {
  err({
    kind: "worker.claim_error",
    message: e?.message,
    stack: e?.stack,
    hint: "Check PHASE27_CLAIM_ONE_SQL syntax/params and tasks schema. This error is now non-silent.",
  });
  // Backoff a bit so logs don't melt.
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
log({
  kind: "worker.claimed",
  claimed: claimedRow,
  claimed_keys: Object.keys(claimedRow || {}),
});
if (markSuccessFile) {
  try {
    const task_id = claimedRow.task_id ?? claimedRow.id ?? claimedRow.taskId ?? null;
    const run_id = claimedRow.run_id ?? claimedRow.runId ?? null;

    if (hasDollarParams(markSuccessFile.sql)) {
      // Convention: $1=task_id, $2=run_id, $3=owner, $4=actor, $5=ts_ms
      await pool.query(markSuccessFile.sql, [task_id, run_id, owner, actor, ms()]);
    } else {
      await pool.query(markSuccessFile.sql);
    }
    log({ kind: "worker.mark_success_ok", task_id, run_id });
  } catch (e) {
    err({ kind: "worker.mark_success_error", message: e?.message, stack: e?.stack });
    if (markFailureFile) {
      try {
        const task_id = claimedRow.task_id ?? claimedRow.id ?? claimedRow.taskId ?? null;
        const run_id = claimedRow.run_id ?? claimedRow.runId ?? null;
        const reason = e?.message || "mark_success_failed";

        if (hasDollarParams(markFailureFile.sql)) {
          // Convention: $1=task_id, $2=run_id, $3=owner, $4=actor, $5=ts_ms, $6=reason
          await pool.query(markFailureFile.sql, [task_id, run_id, owner, actor, ms(), reason]);
        } else {
          await pool.query(markFailureFile.sql);
        }
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

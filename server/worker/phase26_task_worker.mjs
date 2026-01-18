import fs from "node:fs";
import path from "node:path";
import { computeBackoffMs } from "./backoff.mjs";
import { getPool, markSuccess, markFailure } from "./phase27_markers.mjs";
import { emitTaskEvent } from "../task_events_emit.mjs";

function ms() { return Date.now(); }
function sleep(msi) { return new Promise((r) => setTimeout(r, msi)); }

function mustEnv(name) {
const v = process.env[name];
if (v == null || String(v).trim() === "") throw new Error(`worker: missing env `);
return String(v).trim();
}

function readSql(relPath) {
const abs = path.isAbsolute(relPath) ? relPath : path.join(process.cwd(), relPath);
return fs.readFileSync(abs, "utf8");
}

function sqlNeedsParams(sql) {
return /$\d+/.test(String(sql || ""));
}

const FAIL_SQL_PATH = process.env.PHASE27_MARK_FAILURE_SQL ? String(process.env.PHASE27_MARK_FAILURE_SQL).trim() : null;
const SUCC_SQL_PATH = process.env.PHASE27_MARK_SUCCESS_SQL ? String(process.env.PHASE27_MARK_SUCCESS_SQL).trim() : null;
const CLAIM_SQL_PATH = process.env.PHASE27_CLAIM_ONE_SQL ? String(process.env.PHASE27_CLAIM_ONE_SQL).trim() : "server/worker/phase27_claim_one.sql";

const BACKOFF_BASE_MS = Number(process.env.PHASE27_BACKOFF_BASE_MS || 1000);
const BACKOFF_CAP_MS = Number(process.env.PHASE27_BACKOFF_CAP_MS || (5 * 60 * 1000));
const JITTER_PCT = Number(process.env.PHASE27_BACKOFF_JITTER_PCT || 0.2);

const POLL_MS = Number(process.env.WORKER_POLL_MS || 500);

async function claimOneTask(pool) {
const owner = process.env.WORKER_OWNER || `worker-`;
const leaseMs = Number(process.env.WORKER_LEASE_MS || 15000);
const leaseUntil = new Date(Date.now() + leaseMs);

const sql = readSql(CLAIM_SQL_PATH);
const values = sqlNeedsParams(sql) ? [owner, leaseUntil] : [];
const r = await pool.query(sql, values);
return r.rows[0] || null;
}

async function execTask(task) {
// TODO: replace with Phase 26 executor hook if needed
return { ok: true, task_id: task.id };
}

async function handleSuccess({ pool, task }) {
const succ = SUCC_SQL_PATH || mustEnv("PHASE27_MARK_SUCCESS_SQL");
await markSuccess({ pool, sqlPath: succ, task_id: task.id, run_id: task.run_id });

await emitTaskEvent({
pool,
kind: "task.completed",
task_id: task.id,
run_id: task.run_id,
actor: "worker",
payload: { ts: ms() },
});
}

async function handleFailure({ pool, task, err }) {
const fail = FAIL_SQL_PATH || mustEnv("PHASE27_MARK_FAILURE_SQL");

const attempt = Number(task.retry_count ?? task.attempt ?? task.attempt_count ?? 1);

const backoff_ms = computeBackoffMs({
attempt,
baseMs: BACKOFF_BASE_MS,
capMs: BACKOFF_CAP_MS,
jitterPct: JITTER_PCT,
});
await markFailure({
pool,
sqlPath: fail,
task_id: task.id,
run_id: task.run_id,
backoff_ms,
error: {
message: err?.message || String(err),
name: err?.name || "Error",
stack: err?.stack || null,
ts: ms(),
},
});

await emitTaskEvent({
pool,
kind: "task.failed",
task_id: task.id,
run_id: task.run_id,
actor: "worker",
payload: { ts: ms(), backoff_ms },
});

await emitTaskEvent({
pool,
kind: "task.requeued",
task_id: task.id,
run_id: task.run_id,
actor: "worker",
payload: { ts: ms(), backoff_ms },
});
}

export async function runWorkerLoop() {
const pool = getPool();

while (true) {
const task = await claimOneTask(pool);
if (!task) {
await sleep(POLL_MS);
continue;
}
await emitTaskEvent({
  pool,
  kind: "task.running",
  task_id: task.id,
  run_id: task.run_id,
  actor: "worker",
  payload: { ts: ms(), lease_expires_at: task.lease_expires_at ?? null },
});

try {
  await execTask(task);
  await handleSuccess({ pool, task });
} catch (e) {
  await handleFailure({ pool, task, err: e });
}
}
}

if (import.meta.url === file://${process.argv[1]}) {
runWorkerLoop().catch((e) => {
console.error("[worker] fatal", e);
process.exit(1);
});
}

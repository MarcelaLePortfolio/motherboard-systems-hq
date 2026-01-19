import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { Pool } from "pg";

function ms() { return Date.now(); }
function sleep(t) { return new Promise(r => setTimeout(r, t)); }

function reqEnv(k) {
  const v = process.env[k];
  if (!v) throw new Error(`missing env: ${k}`);
  return v;
}

function readSqlMaybe(filePath) {
  if (!filePath) return null;
  const p = path.resolve(filePath);
  if (!fs.existsSync(p)) return null;
  return fs.readFileSync(p, "utf8");
}

function errToJson(e) {
  if (!e) return { message: "unknown error" };
  const obj = {
    name: e.name || "Error",
    message: e.message || String(e),
    stack: e.stack || null,
  };
  if (e.code) obj.code = e.code;
  return obj;
}

function clampInt(n, lo, hi, fallback) {
  const x = Number.parseInt(String(n ?? ""), 10);
  if (!Number.isFinite(x)) return fallback;
  return Math.max(lo, Math.min(hi, x));
}

function backoffMs(attempt, baseMs, maxMs) {
  const a = Math.max(1, attempt);
  const raw = baseMs * (2 ** (a - 1));
  return Math.min(raw, maxMs);
}

function taskPayload(task) {
  // Your current DB schema uses tasks.meta jsonb (not tasks.payload)
  // Keep compatibility if payload exists later.
  return task.payload ?? task.meta ?? null;
}

async function insertTaskEvent(pool, { kind, task_id, run_id = null, actor = null, payload = null }) {
  // Your task_events.payload is TEXT NOT NULL. Store JSON string.
  const q = `
    insert into task_events(kind, payload, task_id, run_id, actor)
    values ($1, $2, $3, $4, $5)
  `;
  const payloadText = JSON.stringify(payload ?? {});
  await pool.query(q, [kind, payloadText, String(task_id), run_id, actor]);
}

async function execTask(task) {
  const payload = taskPayload(task) || {};
  if (payload.force_fail === true || payload.__force_fail === true) {
    throw new Error("phase28 smoke: forced failure");
  }
  await sleep(50);
  return { ok: true, ts: ms() };
}

async function handleFailure(pool, task, error) {
  const maxAttempts = clampInt(process.env.WORKER_MAX_ATTEMPTS, 1, 50, 3);
  const baseBackoff = clampInt(process.env.WORKER_BACKOFF_BASE_MS, 10, 60000, 2000);
  const maxBackoff = clampInt(process.env.WORKER_BACKOFF_MAX_MS, 10, 86400000, 60000);

  // your schema has attempt (int not null default 0). we also added attempts; tolerate both.
  const prevAttempts = Number.isFinite(task.attempts) ? Number(task.attempts)
                    : Number.isFinite(task.attempt) ? Number(task.attempt)
                    : 0;
  const nextAttempts = prevAttempts + 1;

  const lastError = {
    ...errToJson(error),
    ts: ms(),
    attempt: nextAttempts,
  };

  // always emit task.failed (even if we retry)
  await insertTaskEvent(pool, {
    kind: "task.failed",
    task_id: task.id,
    run_id: task.run_id || null,
    actor: "worker",
    payload: lastError,
  });

  const markFailureSql = readSqlMaybe(process.env.PHASE27_MARK_FAILURE_SQL);
  if (!markFailureSql) throw new Error("PHASE27_MARK_FAILURE_SQL required for this DB schema");

  if (nextAttempts >= maxAttempts) {
    await pool.query(markFailureSql, [
      task.id,
      "failed",
      nextAttempts,
      null,
      JSON.stringify(lastError),
    ]);
    return { terminal: true, attempts: nextAttempts };
  }

  const delay = backoffMs(nextAttempts, baseBackoff, maxBackoff);
  const nextAvail = new Date(Date.now() + delay).toISOString();

  await pool.query(markFailureSql, [
    task.id,
    "queued",
    nextAttempts,
    nextAvail,
    JSON.stringify(lastError),
  ]);

  await insertTaskEvent(pool, {
    kind: "task.retry_scheduled",
    task_id: task.id,
    run_id: task.run_id || null,
    actor: "worker",
    payload: { ts: ms(), attempt: nextAttempts, delay_ms: delay, next_available_at: nextAvail },
  });

  return { terminal: false, attempts: nextAttempts, delay_ms: delay, next_available_at: nextAvail };
}

async function main() {
  const POSTGRES_URL = reqEnv("POSTGRES_URL");
  const owner = process.env.WORKER_OWNER || `worker-${process.pid}`;
  const maxClaims = clampInt(process.env.WORKER_MAX_CLAIMS, 1, 10000, 100);

  const pool = new Pool({ connectionString: POSTGRES_URL });

  const claimOneSql = readSqlMaybe(process.env.PHASE27_CLAIM_ONE_SQL);
  const markSuccessSql = readSqlMaybe(process.env.PHASE27_MARK_SUCCESS_SQL);
  const markFailureSql = readSqlMaybe(process.env.PHASE27_MARK_FAILURE_SQL);

  if (!claimOneSql) throw new Error("PHASE27_CLAIM_ONE_SQL required for this DB schema");
  if (!markSuccessSql) throw new Error("PHASE27_MARK_SUCCESS_SQL required for this DB schema");
  if (!markFailureSql) throw new Error("PHASE27_MARK_FAILURE_SQL required for this DB schema");

  let claimed = 0;

  try {
    for (; claimed < maxClaims; claimed++) {
      const run_id = `${owner}-${ms()}-${Math.random().toString(16).slice(2)}`;

      const r = await pool.query(claimOneSql, [run_id, owner]);
      const task = r.rows && r.rows[0];
      if (!task) break;

      await insertTaskEvent(pool, {
        kind: "task.running",
        task_id: task.id,
        run_id,
        actor: owner,
        payload: { ts: ms() },
      });

      try {
        const result = await execTask(task);

        await pool.query(markSuccessSql, [task.id]);

        await insertTaskEvent(pool, {
          kind: "task.completed",
          task_id: task.id,
          run_id,
          actor: owner,
          payload: { ts: ms(), result },
        });
      } catch (e) {
        await handleFailure(pool, { ...task, run_id }, e);
      }
    }
  } finally {
    await pool.end().catch(() => {});
  }

  console.log(`[worker] done owner=${owner} claimed=${claimed}`);
}

main().catch((e) => {
  console.error("[worker] fatal", e);
  process.exitCode = 1;
});

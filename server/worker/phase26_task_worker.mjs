import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { Pool } from "pg";

// [phase31.6] keep worker long-running by default; allow oneshot for dev
const WORKER_ONESHOT = String(process.env.WORKER_ONESHOT || "").trim() === "1";
const WORKER_IDLE_SLEEP_MS = Number(process.env.WORKER_IDLE_SLEEP_MS || process.env.PHASE26_TICK_MS || 500);


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
  if (!e) return { name: "Error", message: "unknown error", stack: null };
  return {
    name: e.name || "Error",
    message: e.message || String(e),
    stack: e.stack || null,
    code: e.code || null,
  };
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
  return task.payload ?? task.meta ?? null;
}

let __HAS_EVENTS_PAYLOAD_JSONB = null;
async function hasTaskEventsPayloadJsonb(pool) {
  if (__HAS_EVENTS_PAYLOAD_JSONB !== null) return __HAS_EVENTS_PAYLOAD_JSONB;
  const r = await pool.query(
    "select count(*)::int as n from information_schema.columns where table_name='task_events' and column_name='payload_jsonb'"
  );
  __HAS_EVENTS_PAYLOAD_JSONB = (r.rows?.[0]?.n || 0) > 0;
  return __HAS_EVENTS_PAYLOAD_JSONB;
}

async function insertTaskEvent(pool, { kind, task_id, run_id = null, actor = null, payload = null }) {
  const payloadObj = payload ?? {};
  const payloadText = JSON.stringify(payloadObj);

  if (await hasTaskEventsPayloadJsonb(pool)) {
    await pool.query(
      "insert into task_events(kind, payload, payload_jsonb, task_id, run_id, actor) values ($1,$2,$3::jsonb,$4,$5,$6)",
      [kind, payloadText, JSON.stringify(payloadObj), String(task_id), run_id, actor]
    );
    return;
  }

  await pool.query(
    "insert into task_events(kind, payload, task_id, run_id, actor) values ($1,$2,$3,$4,$5)",
    [kind, payloadText, String(task_id), run_id, actor]
  );
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

  const prevAttempts = Number.isFinite(task.attempts) ? Number(task.attempts)
    : Number.isFinite(task.attempt) ? Number(task.attempt)
    : 0;

  const nextAttempts = prevAttempts + 1;

  const lastError = {
    ...errToJson(error),
    ts: ms(),
    attempt: nextAttempts,
  };

  await insertTaskEvent(pool, {
    kind: "task.failed",
    task_id: task.id,
    run_id: task.run_id || null,
    actor: "worker",
    payload: lastError,
  });

  const markFailureSql = readSqlMaybe(process.env.PHASE27_MARK_FAILURE_SQL);
  if (!markFailureSql) throw new Error("PHASE27_MARK_FAILURE_SQL required");

  if (nextAttempts >= maxAttempts) {
    await pool.query(markFailureSql, [
      task.id,
      "failed",
      nextAttempts,
      null,
      JSON.stringify(lastError),
    ]);
    return;
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
}

async function main() {
  const POSTGRES_URL = reqEnv("POSTGRES_URL");
  const owner = process.env.WORKER_OWNER || `worker-${process.pid}`;
  const maxClaims = clampInt(process.env.WORKER_MAX_CLAIMS, 1, 10000, 100);

  const pool = new Pool({ connectionString: POSTGRES_URL });

  const claimOneSql = readSqlMaybe(process.env.PHASE27_CLAIM_ONE_SQL);
  const markSuccessSql = readSqlMaybe(process.env.PHASE27_MARK_SUCCESS_SQL);
  const markFailureSql = readSqlMaybe(process.env.PHASE27_MARK_FAILURE_SQL);

  if (!claimOneSql || !markSuccessSql || !markFailureSql) {
    throw new Error("PHASE27 SQL envs required");
  }

  let claimed = 0;

  try {
    while (true) {
      let didClaim = false;
    for (; claimed < maxClaims; claimed++) {
      const run_id = `${owner}-${ms()}-${Math.random().toString(16).slice(2)}`;
      const r = await pool.query(claimOneSql, [run_id, owner]);
      const task = r.rows && r.rows[0];
      if (!task) break;
            didClaim = true;

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
      if (WORKER_ONESHOT) break;
      if (!didClaim) await sleep(WORKER_IDLE_SLEEP_MS);
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

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FAIL_SQL="$(rg -n --files -S 'phase27_mark_failure\.sql' | head -n 1 || true)"
SUCC_SQL="$(rg -n --files -S 'phase27_mark_success\.sql' | head -n 1 || true)"

if [[ -z "${FAIL_SQL}" || -z "${SUCC_SQL}" ]]; then
  echo "ERROR: Could not find phase27_mark_failure.sql / phase27_mark_success.sql in repo."
  echo "Found fail='${FAIL_SQL}' success='${SUCC_SQL}'"
  exit 1
fi

WORKER_FILE="$(
  rg -n --files -S \
    -g'*.mjs' -g'*.js' \
    'task\.running|task\.completed|task\.failed|lease|claim' server scripts 2>/dev/null \
  | xargs -I{} sh -lc "rg -n -S 'task\\.running' '{}' >/dev/null 2>&1 && rg -n -S 'task\\.completed|task\\.failed' '{}' >/dev/null 2>&1 && echo '{}'" \
  | head -n 1 || true
)"

if [[ -z "${WORKER_FILE}" ]]; then
  echo "ERROR: Could not identify worker loop file automatically."
  echo "Hint: ensure the worker loop lives under server/ or scripts/ and emits task.running + task.completed/failed."
  exit 1
fi

echo "Using:"
echo "  WORKER_FILE=${WORKER_FILE}"
echo "  FAIL_SQL=${FAIL_SQL}"
echo "  SUCC_SQL=${SUCC_SQL}"

mkdir -p server/worker

cat > server/worker/backoff.mjs <<'JS'
export function computeBackoffMs({
  attempt = 1,
  baseMs = 1000,
  capMs = 5 * 60 * 1000,
  jitterPct = 0.2,
} = {}) {
  const a = Math.max(1, Number(attempt) || 1);
  const base = Math.max(1, Number(baseMs) || 1000);
  const cap = Math.max(base, Number(capMs) || base);
  const pct = Math.min(1, Math.max(0, Number(jitterPct) || 0));

  let backoff = base * Math.pow(2, a - 1);
  if (!Number.isFinite(backoff) || backoff < 0) backoff = base;
  if (backoff > cap) backoff = cap;

  const jitterMax = Math.floor(backoff * pct);
  const jitter = jitterMax > 0 ? Math.floor(Math.random() * (jitterMax + 1)) : 0;

  return Math.floor(backoff + jitter);
}
JS

cat > server/worker/phase27_markers.mjs <<'JS'
import fs from "node:fs";
import path from "node:path";
import { Pool } from "pg";

function mustEnv(name) {
  const v = process.env[name];
  return (v && String(v).trim()) ? String(v).trim() : null;
}

export function getPool() {
  if (globalThis.__DB_POOL) return globalThis.__DB_POOL;

  const url =
    mustEnv("POSTGRES_URL") ||
    mustEnv("DATABASE_URL") ||
    mustEnv("PGURL");

  if (!url) throw new Error("worker: missing POSTGRES_URL/DATABASE_URL/PGURL");

  const pool = new Pool({ connectionString: url });
  globalThis.__DB_POOL = pool;
  return pool;
}

function readSql(sqlPath) {
  const abs = path.isAbsolute(sqlPath) ? sqlPath : path.join(process.cwd(), sqlPath);
  return fs.readFileSync(abs, "utf8");
}

export async function markSuccess({ pool, sqlPath, task_id, run_id }) {
  const sql = readSql(sqlPath);
  return pool.query(sql, [task_id, run_id]);
}

export async function markFailure({
  pool,
  sqlPath,
  task_id,
  run_id,
  error = null,
  backoff_ms = null,
}) {
  const sql = readSql(sqlPath);
  const errStr =
    error == null ? null :
    (typeof error === "string" ? error : JSON.stringify(error));

  // Convention: $1 task_id, $2 run_id, $3 backoff_ms, $4 error
  return pool.query(sql, [task_id, run_id, backoff_ms, errStr]);
}
JS
cat > "${WORKER_FILE}" <<'JS'
import { computeBackoffMs } from "../worker/backoff.mjs";
import { getPool, markSuccess, markFailure } from "../worker/phase27_markers.mjs";
import { emitTaskEvent } from "../task_events_emit.mjs";

function ms() { return Date.now(); }
function sleep(msi) { return new Promise(r => setTimeout(r, msi)); }

const FAIL_SQL_PATH = process.env.PHASE27_MARK_FAILURE_SQL || "__FAIL_SQL_PATH__";
const SUCC_SQL_PATH = process.env.PHASE27_MARK_SUCCESS_SQL || "__SUCC_SQL_PATH__";

const BACKOFF_BASE_MS = Number(process.env.PHASE27_BACKOFF_BASE_MS || 1000);
const BACKOFF_CAP_MS  = Number(process.env.PHASE27_BACKOFF_CAP_MS  || (5 * 60 * 1000));
const JITTER_PCT      = Number(process.env.PHASE27_BACKOFF_JITTER_PCT || 0.2);

const POLL_MS = Number(process.env.WORKER_POLL_MS || 500);

async function claimOneTask(pool) {
  const owner = process.env.WORKER_OWNER || `worker-${process.pid}`;
  const leaseMs = Number(process.env.WORKER_LEASE_MS || 15000);
  const leaseUntil = new Date(Date.now() + leaseMs);

  const q = `
  with c as (
    select id
    from tasks
    where
      (coalesce(status,'') in ('created','queued','requeued') or status is null)
      and (coalesce(next_run_at, to_timestamp(0)) <= now())
    order by coalesce(priority,0) desc, id asc
    for update skip locked
    limit 1
  )
  update tasks t
  set
    status = 'running',
    run_id = coalesce(t.run_id, gen_random_uuid()::text),
    lease_owner = $1,
    lease_expires_at = $2,
    updated_at = now()
  from c
  where t.id = c.id
  returning t.*;
  `;

  try {
    const r = await pool.query(q, [owner, leaseUntil]);
    return r.rows[0] || null;
  } catch (e) {
    const run_id = `${owner}-${Date.now()}`;
    const q2 = `
    with c as (
      select id
      from tasks
      where
        (coalesce(status,'') in ('created','queued','requeued') or status is null)
        and (coalesce(next_run_at, to_timestamp(0)) <= now())
      order by coalesce(priority,0) desc, id asc
      for update skip locked
      limit 1
    )
    update tasks t
    set
      status = 'running',
      run_id = coalesce(t.run_id, $3),
      lease_owner = $1,
      lease_expires_at = $2,
      updated_at = now()
    from c
    where t.id = c.id
    returning t.*;
    `;
    const r2 = await pool.query(q2, [owner, leaseUntil, run_id]);
    return r2.rows[0] || null;
  }
}

async function execTask(task) {
  // TODO: replace with your Phase 26 executor hook if needed
  return { ok: true, task_id: task.id };
}

async function handleSuccess({ pool, task }) {
  await markSuccess({ pool, sqlPath: SUCC_SQL_PATH, task_id: task.id, run_id: task.run_id });

  await emitTaskEvent({
    pool,
    kind: "task.completed",
    task_id: task.id,
    run_id: task.run_id,
    actor: "worker",
    payload: { ts: ms() }
  });
}

async function handleFailure({ pool, task, err }) {
  const attempt =
    Number(task.retry_count ?? task.attempt ?? task.attempt_count ?? 1);

  const backoff_ms = computeBackoffMs({
    attempt,
    baseMs: BACKOFF_BASE_MS,
    capMs: BACKOFF_CAP_MS,
    jitterPct: JITTER_PCT,
  });

  await markFailure({
    pool,
    sqlPath: FAIL_SQL_PATH,
    task_id: task.id,
    run_id: task.run_id,
    backoff_ms,
    error: {
      message: err?.message || String(err),
      name: err?.name || "Error",
      stack: err?.stack || null,
      ts: ms(),
    }
  });

  await emitTaskEvent({
    pool,
    kind: "task.failed",
    task_id: task.id,
    run_id: task.run_id,
    actor: "worker",
    payload: { ts: ms(), backoff_ms }
  });

  await emitTaskEvent({
    pool,
    kind: "task.requeued",
    task_id: task.id,
    run_id: task.run_id,
    actor: "worker",
    payload: { ts: ms(), backoff_ms }
  });
}

export async function runWorkerLoop() {
  const pool = getPool();

  if (FAIL_SQL_PATH.includes("__FAIL_SQL_PATH__") || SUCC_SQL_PATH.includes("__SUCC_SQL_PATH__")) {
    throw new Error("worker: PHASE27_MARK_FAILURE_SQL / PHASE27_MARK_SUCCESS_SQL not set");
  }

  // eslint-disable-next-line no-constant-condition
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
      payload: { ts: ms(), lease_expires_at: task.lease_expires_at ?? null }
    });

    try {
      await execTask(task);
      await handleSuccess({ pool, task });
    } catch (err) {
      await handleFailure({ pool, task, err });
    }
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  runWorkerLoop().catch((e) => {
    console.error("[worker] fatal", e);
    process.exit(1);
  });
}
JS
perl -0777 -i -pe "s|__FAIL_SQL_PATH__|$FAIL_SQL|g; s|__SUCC_SQL_PATH__|$SUCC_SQL|g" "${WORKER_FILE}"

echo "OK: wrote server/worker/* and patched ${WORKER_FILE}"

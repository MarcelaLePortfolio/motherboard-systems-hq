import { computeBackoffMs } from "./backoff.mjs";
import { getPool, markSuccess, markFailure } from "./phase27_markers.mjs";
import { emitTaskEvent } from "../task_events_emit.mjs";

function ms() { return Date.now(); }
function sleep(msi) { return new Promise(r => setTimeout(r, msi)); }

const FAIL_SQL_PATH = "";
const SUCC_SQL_PATH = "";

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
  // TODO: replace with Phase 26 executor hook if needed
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
  const attempt = Number(task.retry_count ?? task.attempt ?? task.attempt_count ?? 1);

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

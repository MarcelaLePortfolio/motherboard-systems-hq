import { Pool } from "pg";

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }
function nowMs() { return Date.now(); }

async function ensurePgPool() {
  const url = process.env.POSTGRES_URL || process.env.DATABASE_URL;
  if (!url) throw new Error("phase26_task_worker: POSTGRES_URL (or DATABASE_URL) is required");
  return new Pool({ connectionString: url });
}

async function emitTaskEvent(pool, kind, task_id, run_id, actor, payload = {}) {
  const p = { ts: nowMs(), task_id, run_id, actor, ...payload };
  await pool.query(
    `insert into task_events(kind, payload) values ($1, $2::jsonb)`,
    [kind, JSON.stringify(p)]
  );
}
async function claimNextQueuedTask(pool, actor) {
  const q = `
    with next as (
      select id
      from tasks
      where status = 'queued'
      order by id asc
      for update skip locked
      limit 1
    )
    update tasks
    set status = 'running'
    where id in (select id from next)
    returning *;
  `;
  const r = await pool.query(q);
  if (!r.rows || r.rows.length === 0) return null;

  const row = r.rows[0];
  const task_id = row.id;
  const run_id = `run_${task_id}_${nowMs()}`;
  await emitTaskEvent(pool, "task.running", task_id, run_id, actor, { status: "running" });
  return { row, task_id, run_id };
}


function shouldFail(taskRow) {
  const p = taskRow?.payload;
  if (!p) return false;
  if (p.fail === true) return true;
  if (p.should_fail === true) return true;
  if (typeof p.fail === "string" && p.fail.toLowerCase() === "true") return true;
  return false;
}

async function completeTask(pool, task_id, run_id, actor, ok, extra = {}) {
  const status = ok ? "completed" : "failed";
  await pool.query(`update tasks set status = $1 where id = $2`, [status, task_id]);

  const kind = ok ? "task.completed" : "task.failed";
  await emitTaskEvent(pool, kind, task_id, run_id, actor, { status, ...extra });
}


async function executeTask(pool, taskRow, task_id, run_id, actor) {
  const fail = shouldFail(taskRow);
  if (fail) {
    await completeTask(pool, task_id, run_id, actor, false, { error: "phase26: simulated failure via payload flag" });
    return;
  }
  await completeTask(pool, task_id, run_id, actor, true, { result: "phase26: no-op executor completed" });
}

async function main() {
  const actor = process.env.PHASE26_WORKER_ACTOR || "phase26.worker";
  const tickMs = Number(process.env.PHASE26_TICK_MS || 500);

  const pool = await ensurePgPool();

  let stopping = false;
  const stop = () => { stopping = true; };
  process.on("SIGINT", stop);
  process.on("SIGTERM", stop);

  await pool.query("select 1");

  while (!stopping) {
    let claimed = null;

    try {
      claimed = await claimNextQueuedTask(pool, actor);
    } catch {
      await sleep(Math.min(2000, Math.max(250, tickMs)));
      continue;
    }

    if (!claimed) {
      await sleep(tickMs);
      continue;
    }

    try {
      await executeTask(pool, claimed.row, claimed.task_id, claimed.run_id, actor);
    } catch (e) {
      try {
        await completeTask(pool, claimed.task_id, claimed.run_id, actor, false, { error: String(e?.message || e) });
      } catch {}
    }
  }
  await pool.end().catch(() => {});
}

main().catch((e) => {
  console.error("[phase26_task_worker] fatal:", e);
  process.exit(1);
});

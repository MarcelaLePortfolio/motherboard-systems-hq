import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { Pool } from "pg";
import { emitTaskEvent } from "../task_events_emit.mjs";
import { policyShadowEnabled } from "../policy/policy_flags.mjs";
import { policyEvalShadow } from "../policy/policy_eval.mjs";
import { policyAuditWrite } from "../policy/policy_audit.mjs";

// Phase 39: Action Tier pre-execution gate (A allowed; B/C blocked)
function __mbIsTierA(t){
  const v = String(t ?? 'A');
  return v === 'A';
}

const PHASE26_DEBUG = String(process.env.PHASE26_DEBUG || "1") === "1";
function dbg(...args) { if (PHASE26_DEBUG) console.log("[phase26][dbg]", ...args); }

function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }
function readSqlFile(p) {
  const abs = path.isAbsolute(p) ? p : path.join(process.cwd(), p);
  return fs.readFileSync(abs, "utf-8");
}
const POSTGRES_URL = process.env.POSTGRES_URL;
if (!POSTGRES_URL) throw new Error("POSTGRES_URL required");
const TICK_MS = Number(process.env.PHASE26_TICK_MS || 500);
const BACKOFF_BASE_MS = Number(process.env.WORKER_BACKOFF_BASE_MS || 2000);
const owner = process.env.WORKER_OWNER || `worker-${process.pid}`;

  // Phase 34 (lease/heartbeat/reclaim) — optional, behind env flag
  const PHASE34_ENABLE_LEASE = String(process.env.PHASE34_ENABLE_LEASE || "") === "1";
  const PHASE34_HEARTBEAT_SQL = process.env.PHASE34_HEARTBEAT_SQL || "server/worker/phase34_heartbeat.sql";
  const PHASE34_RECLAIM_SQL = process.env.PHASE34_RECLAIM_SQL || "server/worker/phase34_reclaim_stale.sql";
  const PHASE34_LEASE_MS = Number(process.env.PHASE34_LEASE_MS || "60000");
  const PHASE34_STALE_HEARTBEAT_MS = Number(process.env.PHASE34_STALE_HEARTBEAT_MS || String(PHASE34_LEASE_MS * 2));

  // If enabled, default the worker SQL env vars to Phase 34 variants (same contract: created->running->completed/failed)
  if (PHASE34_ENABLE_LEASE) {
    process.env.PHASE27_CLAIM_ONE_SQL = process.env.PHASE27_CLAIM_ONE_SQL || "server/worker/phase35_claim_one_pg.sql";
    process.env.PHASE27_MARK_SUCCESS_SQL = process.env.PHASE27_MARK_SUCCESS_SQL || "server/worker/phase35_mark_success_pg.sql";
    process.env.PHASE27_MARK_FAILURE_SQL = process.env.PHASE27_MARK_FAILURE_SQL || "server/worker/phase35_mark_failure_pg.sql";
  }

// Prefer Phase 32 SQL, fall back to Phase 27 (back-compat).
const CLAIM_ONE_PATH = process.env.PHASE32_CLAIM_ONE_SQL || process.env.PHASE27_CLAIM_ONE_SQL;
const MARK_SUCCESS_PATH = process.env.PHASE32_MARK_SUCCESS_SQL || process.env.PHASE27_MARK_SUCCESS_SQL;
const MARK_FAILURE_PATH = process.env.PHASE32_MARK_FAILURE_SQL || process.env.PHASE27_MARK_FAILURE_SQL;

if (!CLAIM_ONE_PATH || !MARK_SUCCESS_PATH || !MARK_FAILURE_PATH) {
  throw new Error("SQL paths required: PHASE32_* (preferred) or PHASE27_* (fallback)");
}
const CLAIM_ONE_SQL = readSqlFile(CLAIM_ONE_PATH);
const MARK_SUCCESS_SQL = readSqlFile(MARK_SUCCESS_PATH);
const MARK_FAILURE_SQL = readSqlFile(MARK_FAILURE_PATH);

// Phase 34 SQL (pg-param) — only used when PHASE34_ENABLE_LEASE=1
const PHASE34_HEARTBEAT_SQL_STR = readSqlFile(process.env.PHASE34_HEARTBEAT_PG_SQL || "server/worker/phase34_heartbeat_pg.sql");
const PHASE34_RECLAIM_SQL_STR = readSqlFile(process.env.PHASE34_RECLAIM_PG_SQL || "server/worker/phase34_reclaim_stale_pg.sql");

const pool = new Pool({ connectionString: POSTGRES_URL });
async function claimOne(c, run_id) {
  const r = await c.query(CLAIM_ONE_SQL, PHASE34_ENABLE_LEASE ? [run_id, owner, PHASE34_LEASE_MS] : [run_id, owner]);
  return r.rows?.[0] || null;
}
async function markSuccess(c, task_id, run_id, actor) {
  const r = await c.query(MARK_SUCCESS_SQL, [String(task_id), run_id ?? null, actor ?? null]);
  return r.rows?.[0] ?? null;
}
async function markFailure(c, task_id, run_id, actor) {
  const r = await c.query(MARK_FAILURE_SQL, [String(task_id), run_id ?? null, actor ?? null]);
  return r.rows?.[0] ?? null;
}
function parseMeta(task) {
  const m = task?.meta;
  if (!m) return null;
  const unwrap = (obj) => {
    if (!obj || typeof obj !== "object") return null;
    // common shapes in this repo:
    // 1) { raw: { meta: {...}, ... } }
    // 2) { meta: {...} }
    // 3) already the meta payload
    return obj.raw?.meta ?? obj.meta ?? obj;
  };
  if (typeof m === "object") return unwrap(m);
  try { return unwrap(JSON.parse(String(m))); } catch { return null; }
}
function shouldFailDeterministically(task) {
  // Minimal deterministic failure hook (Phase 32 verification aid):
  // - meta.force_fail: always fail
  // - meta.fail_n_times: fail while attempts < fail_n_times
  const meta = parseMeta(task) || {};
  const attempts = Number((task?.attempts ?? task?.attempt ?? 0));
  if (meta.force_fail === true) return { fail: true, reason: "meta.force_fail=true" };

  const n = Number(meta.fail_n_times);
  if (Number.isFinite(n) && n > 0 && attempts < n) {
    return { fail: true, reason: `meta.fail_n_times=${n} attempts=${attempts}` };
  }
  return { fail: false, reason: null };
}
async function loop() {
  let backoff = BACKOFF_BASE_MS;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    dbg('tick', { ts: new Date().toISOString(), owner });
    const run_id = `run-${Date.now()}-${Math.random().toString(16).slice(2)}`;
    try {
      const c = await pool.connect();
      try {
    if (policyShadowEnabled(process.env)) {
      const __task = ((typeof payload !== "undefined" ? payload?.task : undefined)) ?? null;
      const __run  = ((typeof payload !== "undefined" ? payload?.run  : undefined)) ?? null;
      const __policyAudit = await policyEvalShadow({ task: __task, run: __run }, process.env);
      await policyAuditWrite(__policyAudit);
    }

        await c.query("BEGIN");
        // phase34 heartbeat + reclaim (optional)
        if (PHASE34_ENABLE_LEASE) {
          try {
            await c.query(PHASE34_HEARTBEAT_SQL_STR, [owner]);
          } catch (e) {
            console.error("[phase34] heartbeat error", e);
          }
          try {
            await c.query(PHASE34_RECLAIM_SQL_STR, [PHASE34_STALE_HEARTBEAT_MS]);
          } catch (e) {
            console.error("[phase34] reclaim error", e);
          }
        }

        dbg('claim_attempt');
          const task = await claimOne(c, run_id);

          // Phase 39: SQL-level value gate returns gate_action
          // - REFUSE: worker must not treat as claimed work; log + continue cleanly
          // - CLAIM (or missing): proceed with normal flow
          const gateAction = String(task?.gate_action ?? task?.gateAction ?? "");
          if (gateAction === "REFUSE") {
            const tier = String(task?.action_tier ?? task?.actionTier ?? "UNKNOWN");
            console.log("VALUE_GATE_REFUSE");
            console.log("[phase39] VALUE_GATE_REFUSE", { owner, tier, task_id: task?.task_id ?? task?.taskId ?? null, id: task?.id ?? null });
            await c.query("COMMIT");
            c.release();
            await sleep(TICK_MS);
            backoff = BACKOFF_BASE_MS;
            continue;
          }

  // Phase 39: Action Tier pre-execution gate
  if (!__mbIsTierA(task?.action_tier ?? task?.actionTier)) {
    const __tier = String((task?.action_tier ?? task?.actionTier) ?? '');
    const tier = (__tier && __tier.trim()) ? __tier.trim() : 'UNKNOWN';
    const e = new Error(`Blocked by action_tier gate: ${tier}`);
    e.code = 'ACTION_TIER_BLOCKED';
    throw e;
  }
        if (!task) {
            dbg('claim_none');
            await c.query("COMMIT");
            c.release();
            await sleep(TICK_MS);
            backoff = BACKOFF_BASE_MS;
            continue;
          }

        // Phase35: workers must use stable string task_id (tN), not numeric id.
        const stableTaskId = String(task.task_id ?? (`t${task.id}`));
        const workerActor = process.env.PHASE26_WORKER_ACTOR || process.env.WORKER_OWNER || "worker";

        await c.query("COMMIT");
        if (!task) {
          c.release();
          await sleep(TICK_MS);
          backoff = BACKOFF_BASE_MS;
          continue;
        }
        await emitTaskEvent({
          pool,
          kind: "task.running",
          task_id: (task.task_id || String(task.id)),
          run_id: task.run_id || run_id,
          actor: owner,
          payload: {
            ts: Date.now(),
            attempts: task.attempts,
            max_attempts: task.max_attempts,
          },
        });
        const verdict = shouldFailDeterministically(task);
        if (verdict.fail) {
          const failedRow = await markFailure(c, stableTaskId, task.lease_epoch, `phase32_deterministic_failure: ${verdict.reason}`);

          if (failedRow) {
            await emitTaskEvent({
              pool,
              kind: failedRow.status === "failed" ? "task.failed" : "task.retry_scheduled",
              task_id: (failedRow.task_id || String(failedRow.id)),
              run_id: failedRow.run_id || run_id,
              actor: owner,
              payload: {
                ts: Date.now(),
                attempts: failedRow.attempts,
                max_attempts: failedRow.max_attempts,
                next_run_at: failedRow.next_run_at,
                status: failedRow.status,
                last_error: failedRow.last_error,
              },
            });
          }

          c.release();
          backoff = BACKOFF_BASE_MS;
          continue;
        }
        const done = await markSuccess(c, stableTaskId, run_id, workerActor);
        if (done) {
          await emitTaskEvent({
            pool,
            kind: "task.completed",
            task_id: (done.task_id || String(done.id)),
            run_id: done.run_id || run_id,
            actor: owner,
            payload: {
              ts: Date.now(),
              attempts: done.attempts,
              max_attempts: done.max_attempts,
            },
          });
        }
        c.release();
        backoff = BACKOFF_BASE_MS;
      } catch (e) {
        try { await pool.query("ROLLBACK"); } catch {}
        throw e;
      }
    } catch (e) {
      console.error("[worker] loop error", e);
      dbg('sleep_backoff', { backoff });
        await sleep(backoff);
      backoff = Math.min(backoff * 2, 30000);
    }
  }
}
loop().catch((e) => {
  console.error("[worker] fatal", e);
  process.exit(1);
});

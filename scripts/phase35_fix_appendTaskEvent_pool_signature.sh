#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
python3 - <<'PY'
from __future__ import annotations
from pathlib import Path

p = Path("server/task-events.mjs")
src = p.read_text(encoding="utf-8")

needle = "export async function appendTaskEvent("
i = src.find(needle)
if i == -1:
    raise SystemExit("patch_failed: appendTaskEvent export not found in server/task-events.mjs")

# find function block by brace counting starting at first "{"
brace0 = src.find("{", i)
if brace0 == -1:
    raise SystemExit("patch_failed: could not find '{' for appendTaskEvent")

depth = 0
end = None
for idx in range(brace0, len(src)):
    c = src[idx]
    if c == "{":
        depth += 1
    elif c == "}":
        depth -= 1
        if depth == 0:
            end = idx + 1
            break
if end is None:
    raise SystemExit("patch_failed: could not find end of appendTaskEvent block")

new_block = r'''export async function appendTaskEvent(pool, kind, task_id, payload, opts = undefined) {
  // Phase25 contract: server is the single authoritative writer of task_events.
  // IMPORTANT: callers historically pass (pool, kind, payloadObj). We keep that shape.
  // - If `task_id` is actually the payload (object/string) we treat it as payload and infer task_id.
  // - pool may be omitted; we fall back to globalThis.__DB_POOL.

  const o = (opts && typeof opts === "object") ? opts : {};
  const now = Date.now();

  // Back-compat: appendTaskEvent(pool, kind, payloadObj)
  let payloadIn = payload;
  let taskIdIn = task_id;

  if (payload === undefined && task_id !== undefined && task_id !== null) {
    // called as (pool, kind, payload)
    payloadIn = task_id;
    taskIdIn = null;
  }

  // pool resolution
  pool = pool || globalThis.__DB_POOL;
  if (!pool || typeof pool.query !== "function") {
    throw new Error("phase25: appendTaskEvent missing pool");
  }

  const actor =
    (o.actor && String(o.actor)) ||
    process.env.PHASE26_WORKER_ACTOR ||
    process.env.WORKER_OWNER ||
    "server";

  const run_id = (o.run_id === undefined) ? null : o.run_id;
  const ts = Number.isFinite(o.ts) ? Number(o.ts) : now;

  // Normalize kind + task_id
  const k = String(kind || "");

  function __phase25_taskIdFromObj(obj) {
    return obj?.task_id ?? obj?.taskId ?? obj?.task?.id ?? null;
  }

  const inferredTaskId =
    (taskIdIn == null ? __phase25_taskIdFromObj(payloadIn) : taskIdIn);

  // payload text + jsonb (best-effort parse)
  let payloadText = "";
  let payloadJson = null;

  try {
    if (payloadIn === null || payloadIn === undefined) payloadText = "";
    else if (typeof payloadIn === "string") payloadText = payloadIn;
    else payloadText = JSON.stringify(payloadIn);
  } catch {
    payloadText = String(payloadIn);
  }

  if (o.payload_jsonb !== undefined) {
    payloadJson = o.payload_jsonb;
  } else if (payloadIn && typeof payloadIn === "object") {
    payloadJson = payloadIn;
  } else if (typeof payloadText === "string" && payloadText.length) {
    try { payloadJson = JSON.parse(payloadText); } catch { payloadJson = null; }
  }
  if (payloadJson === undefined) payloadJson = null;

  // Phase 25: Exact-dupe idempotency — if exact (kind,payload) already exists, do nothing.
  try {
    const dup = await pool.query(
      "select 1 as ok from task_events where kind=$1::text and payload=$2::text limit 1",
      [k, payloadText]
    );
    if (dup && (dup.rowCount || dup.rows?.length)) return;
  } catch (_) {
    // If dedupe query fails, continue (do not block writes).
  }

  // Phase 25: Terminal lockout — reject non-terminal lifecycle events after terminal.
  const __PHASE25_LIFECYCLE_KINDS = new Set([
    "task.created","task.queued","task.started","task.progress","task.completed","task.failed","task.canceled",
  ]);
  const __PHASE25_TERMINAL_KINDS = new Set(["task.completed","task.failed","task.canceled"]);

  if (__PHASE25_LIFECYCLE_KINDS.has(k) && inferredTaskId && !__PHASE25_TERMINAL_KINDS.has(k)) {
    try {
      const like = `%\\\"task_id\\\":\\\"${String(inferredTaskId)}\\\"%`;
      const term = await pool.query(
        "select kind from task_events where kind = any($1::text[]) and payload like $2 order by id desc limit 1",
        [Array.from(__PHASE25_TERMINAL_KINDS), like]
      );
      const tk = term?.rows?.[0]?.kind;
      if (tk) throw new Error(`phase25: reject post-terminal event kind=${k} after=${tk}`);
    } catch (e) {
      if (String(e?.message || "").startsWith("phase25:")) throw e;
    }
  }

  await pool.query(
    "insert into task_events(kind, task_id, run_id, actor, ts, payload, payload_jsonb) values ($1::text, $2::text, $3::text, $4::text, $5::bigint, $6::text, $7::jsonb)",
    [k, (inferredTaskId == null ? null : String(inferredTaskId)), run_id, actor, ts, payloadText, payloadJson]
  );
}
'''

patched = src[:i] + new_block + src[end:]

# Safety: ensure we didn't leave a dangling old 3-col insert anywhere
if 'insert into task_events(kind, task_id, payload) values' in patched:
    raise SystemExit("patch_failed: legacy 3-col insert still present")

p.write_text(patched, encoding="utf-8")
print("patched_ok:", p)
PY

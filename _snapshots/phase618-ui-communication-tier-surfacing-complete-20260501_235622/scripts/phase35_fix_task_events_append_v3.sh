#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - <<'PY'
from __future__ import annotations
from pathlib import Path
import sys

p = Path("server/task-events.mjs")
if not p.exists():
    raise SystemExit("patch_failed: missing server/task-events.mjs")

src = p.read_text(encoding="utf-8")

needle = "export async function appendTaskEvent"
i = src.find(needle)
if i < 0:
    raise SystemExit("patch_failed: appendTaskEvent export not found")

# Find opening brace for function
j = src.find("{", i)
if j < 0:
    raise SystemExit("patch_failed: no opening brace after signature")

# Brace-match function body end
depth = 0
in_str = None
esc = False
k = j
while k < len(src):
    ch = src[k]

    if in_str is not None:
        if esc:
            esc = False
        elif ch == "\\":
            esc = True
        elif in_str == "`":
            if ch == "`":
                in_str = None
        else:
            if ch == in_str:
                in_str = None
        k += 1
        continue

    if ch in ("'", '"', "`"):
        in_str = ch
        k += 1
        continue

    if ch == "{":
        depth += 1
    elif ch == "}":
        depth -= 1
        if depth == 0:
            k += 1
            break
    k += 1

if depth != 0:
    raise SystemExit("patch_failed: unbalanced braces while scanning appendTaskEvent")

# Replace appendTaskEvent with Phase25-guarded implementation that writes new columns.
new_block = """export async function appendTaskEvent(kind, task_id, payload, opts = undefined) {
  // Phase25 contract: server is the single authoritative writer of task_events.
  const o = (opts && typeof opts === "object") ? opts : {};
  const now = Date.now();

  // Preserve legacy normalization used elsewhere in this file.
  const k = String(kind || "");
  const taskId = (task_id == null ? __phase25_taskIdFromObj(payload) : task_id);

  const actor =
    (o.actor && String(o.actor)) ||
    process.env.PHASE26_WORKER_ACTOR ||
    process.env.WORKER_OWNER ||
    "server";

  const run_id = (o.run_id === undefined) ? null : o.run_id;
  const ts = Number.isFinite(o.ts) ? Number(o.ts) : now;

  // payload text + jsonb (best-effort parse)
  let payloadText = "";
  let payloadJson = null;

  try {
    if (payload === null || payload === undefined) payloadText = "";
    else if (typeof payload === "string") payloadText = payload;
    else payloadText = JSON.stringify(payload);
  } catch {
    payloadText = String(payload);
  }

  if (o.payload_jsonb !== undefined) {
    payloadJson = o.payload_jsonb;
  } else if (payload && typeof payload === "object") {
    payloadJson = payload;
  } else if (typeof payloadText === "string" && payloadText.length) {
    try {
      payloadJson = JSON.parse(payloadText);
    } catch {
      payloadJson = null;
    }
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
  if (__PHASE25_LIFECYCLE_KINDS.has(k) && taskId && !__PHASE25_TERMINAL_KINDS.has(k)) {
    try {
      const like = `%\\\\\\"task_id\\\\\\":\\\\\\"${String(taskId)}\\\\\\"%`;
      const term = await pool.query(
        "select kind from task_events where kind = any($1::text[]) and payload like $2 order by id desc limit 1",
        [Array.from(__PHASE25_TERMINAL_KINDS), like]
      );
      const tk = term?.rows?.[0]?.kind;
      if (tk) {
        throw new Error(`phase25: reject post-terminal event kind=${k} after=${tk}`);
      }
    } catch (e) {
      if (String(e?.message || "").startsWith("phase25:")) throw e;
    }
  }

  await pool.query(
    "insert into task_events(kind, task_id, run_id, actor, ts, payload, payload_jsonb) values ($1::text, $2::text, $3::text, $4::text, $5::bigint, $6::text, $7::jsonb)",
    [k, (taskId == null ? null : String(taskId)), run_id, actor, ts, payloadText, payloadJson]
  );
}
"""

patched = src[:i] + new_block + src[k:]

# CRITICAL: delete any stray legacy Phase25 block left at top-level after earlier bad patch.
# If we see a top-level "await pool.query("insert into task_events(kind, task_id, payload)" we remove from the
# preceding "  // Phase 25: Exact-dupe idempotency" to the end of file (it only ever belonged inside appendTaskEvent).
marker = 'await pool.query(\n    "insert into task_events(kind, task_id, payload) values'
pos = patched.find(marker)
if pos != -1:
    start = patched.rfind("\n  // Phase 25: Exact-dupe idempotency", 0, pos)
    if start == -1:
        start = patched.rfind("\n// Phase 25: Exact-dupe idempotency", 0, pos)
    if start == -1:
        raise SystemExit("patch_failed: found legacy insert but could not locate Phase25 block start")
    patched = patched[:start] + "\n"

# Safety: ensure no legacy insert remains anywhere
if 'insert into task_events(kind, task_id, payload) values' in patched:
    raise SystemExit("patch_failed: legacy insert still present")

p.write_text(patched, encoding="utf-8")
print("patched_ok:", p)
PY

#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 - <<'PY'
from __future__ import annotations
from pathlib import Path
import re, sys

p = Path("server/task-events.mjs")
if not p.exists():
    alt = Path("server/task_events.mjs")
    if alt.exists():
        p = alt
    else:
        raise SystemExit("patch_failed: expected server/task-events.mjs (or server/task_events.mjs)")

s = p.read_text(encoding="utf-8")

pat = re.compile(
    r'(^\s*export\s+async\s+function\s+appendTaskEvent\s*\([^)]*\)\s*\{\s*\n)([\s\S]*?)(^\s*\}\s*$)',
    re.M
)

m = pat.search(s)
if not m:
    raise SystemExit("patch_failed: did not find appendTaskEvent")

new_fn = """export async function appendTaskEvent(kind, task_id, payload, opts = undefined) {
  const o = (opts && typeof opts === "object") ? opts : {};
  const now = Date.now();

  const actor =
    (o.actor && String(o.actor)) ||
    process.env.PHASE26_WORKER_ACTOR ||
    process.env.WORKER_OWNER ||
    "server";

  const run_id = (o.run_id === undefined) ? null : o.run_id;
  const ts = Number.isFinite(o.ts) ? Number(o.ts) : now;

  let payloadStr = "";
  let payloadJson = null;

  try {
    if (payload === null || payload === undefined) payloadStr = "";
    else if (typeof payload === "string") payloadStr = payload;
    else payloadStr = JSON.stringify(payload);
  } catch {
    payloadStr = String(payload);
  }

  if (o.payload_jsonb !== undefined) {
    payloadJson = o.payload_jsonb;
  } else if (payload && typeof payload === "object") {
    payloadJson = payload;
  } else if (typeof payloadStr === "string" && payloadStr.length) {
    try {
      payloadJson = JSON.parse(payloadStr);
    } catch {
      payloadJson = null;
    }
  }

  if (payloadJson === undefined) payloadJson = null;

  const sql = `
    INSERT INTO task_events(kind, task_id, run_id, actor, ts, payload, payload_jsonb)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
  `.trim();

  return dbQuery(sql, [kind, task_id, run_id, actor, ts, payloadStr, payloadJson]);
}
"""

s2 = s[:m.start()] + new_fn + s[m.end():]

if not all(k in s2 for k in ["payload_jsonb", "run_id", "actor", "ts"]):
    raise SystemExit("patch_failed: missing required columns")

p.write_text(s2, encoding="utf-8")
print(f"patched_ok: {p}")
PY

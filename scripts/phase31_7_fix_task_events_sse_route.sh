#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ROUTE_FILE="$(rg -n --hidden --no-ignore-vcs -S '/events/task-events|events/task-events' server -l \
  | rg -v '\.bak(\.|$)' | head -n 1)"

if [[ -z "${ROUTE_FILE:-}" ]]; then
  echo "ERR: could not locate canonical /events/task-events route (non-bak) under server/" >&2
  exit 1
fi

python3 - <<'PY'
from pathlib import Path
import re

route = Path("scripts/phase31_7_fix_task_events_sse_route.sh").read_text()
import subprocess, shlex
cmd = r"""rg -n --hidden --no-ignore-vcs -S '/events/task-events|events/task-events' server -l | rg -v '\.bak(\.|$)' | head -n 1"""
p = subprocess.run(cmd, shell=True, check=True, stdout=subprocess.PIPE, text=True)
route_file = p.stdout.strip()
rp = Path(route_file)

t = rp.read_text(encoding="utf-8", errors="ignore")
orig = t
t = re.sub(
    r"select\s+id\s*,\s*kind\s*,\s*payload\s*,\s*created_at",
    "select id, kind, payload, payload_jsonb, task_id, run_id, actor, created_at",
    t,
    count=1,
    flags=re.IGNORECASE,
)
if "payload_jsonb" in t and "task_id" in t and "run_id" in t and "actor" in t:
    pat = re.compile(
        r"const\s+q\s*=\s*await\s+pool\.query\(\s*`(?P<sql>[\s\S]*?)`\s*,\s*\[cursor,\s*batchLimit\]\s*\);\s*",
        re.MULTILINE,
    )
    m = pat.search(t)
    if m:
        sql_new = m.group("sql")
        # craft legacy sql by removing the added columns
        sql_legacy = re.sub(
            r"select\s+id\s*,\s*kind\s*,\s*payload\s*,\s*payload_jsonb\s*,\s*task_id\s*,\s*run_id\s*,\s*actor\s*,\s*created_at",
            "select id, kind, payload, created_at",
            sql_new,
            flags=re.IGNORECASE,
        )
        repl = (
            "let q;\n"
            "        try {\n"
            "          q = await pool.query(\n"
            f"          `{sql_new}`,\n"
            "            [cursor, batchLimit]\n"
            "          );\n"
            "        } catch (_e) {\n"
            "          q = await pool.query(\n"
            f"          `{sql_legacy}`,\n"
            "            [cursor, batchLimit]\n"
            "          );\n"
            "        }\n\n"
        )
        t = t[:m.start()] + repl + t[m.end():]
t = re.sub(
    r"data:\s*\{\s*([\s\S]*?)\s*\}\s*,\s*\}\s*\);\s*",
    lambda mm: mm.group(0),  # keep default unless we match the exact block below
    t,
    count=0,
)
t = t.replace(
    "const payload = _safeJsonParse(r.payload);",
    "const payload = _safeJsonParse(r.payload_jsonb ?? r.payload);\n          const taskIdCol = (r.task_id ?? null);\n          const runIdCol  = (r.run_id  ?? null);\n          const actorCol  = (r.actor   ?? null);",
)

t = t.replace(
    "taskId: (payload?.task_id ?? payload?.taskId ?? null),",
    "taskId: (taskIdCol ?? payload?.taskId ?? payload?.task_id ?? null),",
)

t = t.replace(
    "runId: (payload?.run_id ?? payload?.runId ?? null),",
    "runId: (runIdCol ?? payload?.runId ?? payload?.run_id ?? null),",
)

t = t.replace(
    "actor: (payload?.actor ?? null),",
    "actor: (actorCol ?? payload?.actor ?? payload?.owner ?? null),",
)

t = t.replace(
    "ts: (payload?.ts ?? Date.now()),",
    "ts: (payload?.ts ?? Date.now()),",
)

# Ensure meta always carries the parsed payload object (or raw string if legacy)
t = t.replace(
    "meta: payload,",
    "meta: payload,",
)

if t == orig:
    print("no_change", rp)
else:
    rp.write_text(t, encoding="utf-8")
    print("patched_ok", rp)
PY

echo "=== show patched route excerpt ==="
nl -ba "$ROUTE_FILE" | sed -n '70,160p'

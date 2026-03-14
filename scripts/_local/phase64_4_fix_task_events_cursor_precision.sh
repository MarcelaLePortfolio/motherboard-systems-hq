#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path

path = Path("server/routes/task-events-sse.mjs")
text = path.read_text()
original = text

old_first = """          select id, kind, payload, task_id, run_id, actor, created_at
          from task_events
          where created_at > to_timestamp($1 / 1000.0)
          order by created_at asc
          limit $2
"""

new_first = """          select id, kind, payload, task_id, run_id, actor, created_at
          from task_events
          where (extract(epoch from created_at) * 1000)::bigint > $1
          order by created_at asc
          limit $2
"""

old_fallback = """          select id, kind, payload, created_at
          from task_events
          where created_at > to_timestamp($1 / 1000.0)
          order by created_at asc
          limit $2
"""

new_fallback = """          select id, kind, payload, created_at
          from task_events
          where (extract(epoch from created_at) * 1000)::bigint > $1
          order by created_at asc
          limit $2
"""

old_cursor = """        const _ms = (r.created_at instanceof Date) ? r.created_at.getTime() : Date.parse(r.created_at);
          if (Number.isFinite(_ms)) cursor = Math.max(cursor, _ms);
"""

new_cursor = """        const _msRaw = (r.created_at instanceof Date)
          ? r.created_at.getTime()
          : Date.parse(r.created_at);
        const _ms = Number.isFinite(_msRaw) ? Math.floor(_msRaw) : null;
        if (Number.isFinite(_ms)) cursor = Math.max(cursor, _ms);
"""

for old, new in (
    (old_first, new_first),
    (old_fallback, new_fallback),
    (old_cursor, new_cursor),
):
    if old not in text:
        raise SystemExit(f"required block not found in {path}:\\n{old}")
    text = text.replace(old, new, 1)

if text == original:
    raise SystemExit("no changes applied")

path.write_text(text)
print("patched server/routes/task-events-sse.mjs")
PY

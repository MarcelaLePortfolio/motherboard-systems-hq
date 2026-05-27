#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - <<'PY'
from __future__ import annotations
from pathlib import Path
import re, sys

# Patch ONLY exact legacy insert blocks that bypass appendTaskEvent.
# We keep edits deterministic: only replace a known 3-col insert string with a call to appendTaskEvent.
root = Path("server")
paths = sorted([p for p in root.rglob("*.mjs") if p.is_file()])

legacy_sql_pat = re.compile(r'insert\s+into\s+task_events\s*\(\s*kind\s*,\s*task_id\s*,\s*payload\s*\)\s*values', re.I)
changed = []

for p in paths:
    s = p.read_text(encoding="utf-8")
    if "task_events" not in s:
        continue
    if not legacy_sql_pat.search(s):
        continue

    # We only patch the common pattern:
    # await pool.query("insert into task_events(kind, task_id, payload) values ...", [K, TASKID, PAYLOADTEXT]);
    # -> await appendTaskEvent(K, TASKID, PAYLOADOBJ_OR_TEXT);
    #
    # We cannot safely recover payloadJson unless caller already has an object; so we pass the same payload variable
    # used to build payloadText when possible, else pass payloadText.
    #
    # Heuristic: if file contains appendTaskEvent import/use, we assume payload variable exists.
    #
    # We do NOT attempt clever refactors; we replace only if we find BOTH the SQL string literal and the params array
    # on the same statement.

    # Match a single await pool.query(...) statement containing the legacy SQL.
    stmt_pat = re.compile(
        r'await\s+pool\.query\(\s*\n?\s*([\'"])(?P<sql>[^\'"]*insert\s+into\s+task_events\s*\(\s*kind\s*,\s*task_id\s*,\s*payload\s*\)[^\'"]*)\1\s*,\s*\[(?P<args>[^\]]+)\]\s*\)\s*;\s*',
        re.I
    )

    def repl(m: re.Match) -> str:
        args = m.group("args")
        # args like: k, (taskId==null?...), payloadText
        parts = [a.strip() for a in args.split(",")]
        if len(parts) < 3:
            raise ValueError("unexpected args shape")
        kind_expr = parts[0]
        taskid_expr = parts[1]
        payload_expr = parts[2]

        # Prefer payload object if present in this scope: common names payload or obj or body.
        # If payload_expr is payloadText, try to use `payload` if it exists in file; else keep payloadText.
        payload_to_pass = payload_expr
        if re.fullmatch(r'payloadText|payloadStr', payload_expr) and re.search(r'\bpayload\b', s):
            payload_to_pass = "payload"

        return f"await appendTaskEvent({kind_expr}, {taskid_expr}, {payload_to_pass});\n"

    s2, n = stmt_pat.subn(repl, s, count=50)
    if n:
        # Ensure file references appendTaskEvent; if not, add import from task-events.mjs when safe.
        if "appendTaskEvent" not in s2:
            raise SystemExit(f"patch_failed: internal invariant (appendTaskEvent missing) in {p}")

        if "appendTaskEvent" in s2 and "from \"./task-events.mjs\"" not in s2 and "from \"../task-events.mjs\"" not in s2 and "from \"./task-events\"" not in s2:
            # Attempt to add a local import only if file is in server/ (same dir as task-events.mjs may vary).
            # We add ONLY for server/*.mjs (not server/**/subdir) by computing relative path.
            rel = p.relative_to(root)
            # compute ../ depth from rel parent
            depth = len(rel.parents) - 1
            prefix = "./" if depth == 0 else "../" * depth
            imp = f'import {{ appendTaskEvent }} from "{prefix}task-events.mjs";\n'

            # Insert after the first import block line, else at top.
            if re.search(r'^\s*import\s', s2, re.M):
                s2 = re.sub(r'^(?:\s*import[^\n]*\n)+', lambda mm: mm.group(0) + imp, s2, count=1, flags=re.M)
            else:
                s2 = imp + s2

        p.write_text(s2, encoding="utf-8")
        changed.append((str(p), n))

if not changed:
    print("no_changes: no legacy direct inserts matched exact safe pattern")
else:
    print("patched_files:")
    for fp, n in changed:
        print(f"  {fp}: replaced {n} legacy insert(s)")
PY

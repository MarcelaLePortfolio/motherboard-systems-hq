#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - <<'PY'
from pathlib import Path
p = Path("server/task-events.mjs")
s = p.read_text(encoding="utf-8")

# Goal: ensure appendTaskEvent resolves a local var named `pool` before any pool.query usage.
# If code already has: const pool = poolArg || globalThis.__DB_POOL ... we're good.
# If it has different var name (e.g. resolvedPool) but still uses pool.query -> ReferenceError.
if "export async function appendTaskEvent" not in s:
    raise SystemExit("patch_failed: appendTaskEvent not found")

# Heuristic: if file contains "resolvedPool" then rewrite "resolvedPool.query(" -> "pool.query("
# and ensure "const pool =" exists.
changed = False

if "resolvedPool" in s and "const pool =" not in s:
    # try to rename resolvedPool -> pool in common patterns
    s2 = s.replace("resolvedPool.query(", "pool.query(")
    s2 = s2.replace("const resolvedPool =", "const pool =")
    if s2 != s:
        s = s2
        changed = True

# Also fix the inverse case: there is `const pool = ...` but `poolArg` or similar not used consistently.
# Ensure there is a definition line inside appendTaskEvent scope by inserting if missing.
import re

m = re.search(r'export async function appendTaskEvent\s*\((.*?)\)\s*{\s*\n', s, re.DOTALL)
if not m:
    raise SystemExit("patch_failed: cannot parse appendTaskEvent signature")

# Find first 40 lines of function body
start = m.end()
body_head = s[start:start+2000]

if "const pool =" not in body_head and "let pool =" not in body_head:
    # Insert a safe resolver immediately after function open brace.
    insert = "  const pool = arguments[0] || globalThis.__DB_POOL;\n  if (!pool) throw new Error(\"appendTaskEvent: missing pool\");\n"
    s = s[:start] + insert + s[start:]
    changed = True

if not changed:
    print("no_change_needed")
else:
    p.write_text(s, encoding="utf-8")
    print("patched_ok", p)
PY

#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - <<'PY'
from __future__ import annotations
from pathlib import Path
import re, sys

# 1) Find where dbQuery is defined (single source of truth)
candidates = []
for p in Path("server").rglob("*.mjs"):
    s = p.read_text(encoding="utf-8")
    if re.search(r'\bexport\s+(async\s+)?function\s+dbQuery\b', s) or re.search(r'\bexport\s+const\s+dbQuery\b', s):
        candidates.append(p)

if not candidates:
    raise SystemExit("patch_failed: could not find dbQuery export in server/")

# Prefer server/db_pool.mjs or server/db.mjs if present; else first match.
preferred = None
for p in candidates:
    if p.name in ("db_pool.mjs", "db.mjs", "db_query.mjs"):
        preferred = p
        break
dbq_file = preferred or candidates[0]

# 2) Patch any file that calls pool.query without binding pool to call dbQuery instead.
root = Path("server")
patched = []
for p in sorted(root.rglob("*.mjs")):
    s = p.read_text(encoding="utf-8")
    if "pool.query(" not in s:
        continue

    has_pool_binding = bool(re.search(r'\b(const|let|var)\s+pool\b', s)) or bool(re.search(r'\bimport\b[^\n]*\bpool\b', s))
    if has_pool_binding:
        continue

    # Replace all "pool.query(" with "dbQuery("
    s2 = s.replace("pool.query(", "dbQuery(")

    # Ensure import exists (idempotent)
    if "dbQuery(" in s2 and not re.search(r'\bimport\b[^\n]*\bdbQuery\b', s2):
        # compute relative import path from p -> dbq_file
        rel_from = p.parent
        rel = dbq_file.relative_to(root)
        # path from current file to server/<rel>
        up = "../" * len(p.relative_to(root).parents[:-1])
        imp_path = up + str(rel).replace("\\", "/")
        imp_line = f'import {{ dbQuery }} from "{imp_path}";\n'

        # Insert after existing imports if any, else at top
        if re.search(r'^\s*import\s', s2, re.M):
            s2 = re.sub(r'^((?:\s*import[^\n]*\n)+)', r'\1' + imp_line, s2, count=1, flags=re.M)
        else:
            s2 = imp_line + s2

    # Safety: ensure we didn't introduce duplicate import lines
    if len(re.findall(r'\bimport\b[^\n]*\bdbQuery\b', s2)) > 1:
        raise SystemExit(f"patch_failed: duplicate dbQuery import in {p}")

    p.write_text(s2, encoding="utf-8")
    patched.append(str(p))

if not patched:
    print("no_changes: no orphan pool.query sites found")
else:
    print("patched_ok:")
    for fp in patched:
        print(" ", fp)
PY

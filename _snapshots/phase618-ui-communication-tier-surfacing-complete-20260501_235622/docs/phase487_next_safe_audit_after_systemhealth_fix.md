# Phase 487 — Next Safe Audit After systemHealth Fix

## Classification
SAFE — Read-only, bounded inspection

## What we now know
- The `systemHealth.ts` syntax issue is fixed.
- Typecheck is now blocked by a TypeScript 6 deprecation warning in `tsconfig.json`.
- The `server/index.js` check is likely using the wrong expected path for this repo.

## Purpose
Before any further mutation, inspect:
1. the current `tsconfig.json`
2. package scripts / actual entrypoints
3. likely server start targets in the repo

## Commands

echo "=== tsconfig.json (first 80 lines) ==="
sed -n '1,80p' tsconfig.json

echo
echo "=== package.json scripts ==="
python3 - << 'PY'
import json
from pathlib import Path
data = json.loads(Path("package.json").read_text())
for key, value in sorted(data.get("scripts", {}).items()):
    print(f"{key}: {value}")
PY

echo
echo "=== likely server entrypoint candidates (top 40) ==="
find . \
  \( -path './.git' -o -path './node_modules' -o -path './.next' \) -prune -o \
  -type f \
  \( -name 'server.ts' -o -name 'server.js' -o -name 'server.cjs' -o -name 'index.ts' -o -name 'index.js' \) \
  | sort | head -40

## Status
READY — Safe and bounded

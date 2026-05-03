# Phase 487 — Next Safe Audit: Server Targets

## Classification
SAFE — Read-only, bounded inspection

## Purpose
Confirm the actual server entrypoint for this repo and avoid making any mutation based on the wrong assumed path.

## Commands

echo "=== server.ts (first 120 lines) ==="
sed -n '1,120p' server.ts

echo
echo "=== scripts/server.cjs (first 120 lines) ==="
sed -n '1,120p' scripts/server.cjs

echo
echo "=== package.json dependency snapshot ==="
python3 - << 'PY'
import json
from pathlib import Path
data = json.loads(Path("package.json").read_text())
print("dependencies:")
for key, value in sorted(data.get("dependencies", {}).items()):
    print(f"  {key}: {value}")
print()
print("devDependencies:")
for key, value in sorted(data.get("devDependencies", {}).items()):
    print(f"  {key}: {value}")
PY

echo
echo "=== tsconfig include scope ==="
python3 - << 'PY'
import json
from pathlib import Path
data = json.loads(Path("tsconfig.json").read_text())
print(data.get("include", []))
PY

## Status
READY — Safe and bounded

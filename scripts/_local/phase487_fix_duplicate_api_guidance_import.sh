#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

REPORT="docs/phase487_duplicate_api_guidance_import_fix.txt"

python3 - << 'PY'
from pathlib import Path

path = Path("server.mjs")
text = path.read_text(encoding="utf-8")
lines = text.splitlines()

target = 'import apiGuidanceRouter from "./server/routes/api-guidance.mjs";'
matches = [i for i, line in enumerate(lines) if line.strip() == target]

if len(matches) <= 1:
    print(f"No duplicate fix needed. Matches found: {len(matches)}")
else:
    keep = matches[0]
    new_lines = []
    removed = []
    for idx, line in enumerate(lines):
        if line.strip() == target and idx != keep:
            removed.append(idx + 1)
            continue
        new_lines.append(line)
    path.write_text("\n".join(new_lines) + "\n", encoding="utf-8")
    print(f"Removed duplicate import occurrences at lines: {removed}")
    print(f"Kept first occurrence at line: {keep + 1}")
PY

{
  echo "PHASE 487 — DUPLICATE apiGuidanceRouter IMPORT FIX"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo
  echo "[1] Matching import occurrences after fix"
  grep -n 'import apiGuidanceRouter from "./server/routes/api-guidance.mjs";' server.mjs || true
  echo
  echo "[2] Syntax check"
  node --check server.mjs
  echo
  echo "[3] Restarting local server"
  pkill -f 'node server.mjs' 2>/dev/null || true
  nohup node server.mjs > logs/phase487_dashboard_recovery_runtime.log 2>&1 &
  sleep 6
  echo
  echo "[4] HTTP probe"
  curl -I --max-time 10 http://localhost:8080 || true
  echo
  echo "[5] Runtime log tail"
  tail -n 120 logs/phase487_dashboard_recovery_runtime.log || true
  echo
  echo "FIX COMPLETE"
} > "$REPORT"

sed -n '1,260p' "$REPORT"

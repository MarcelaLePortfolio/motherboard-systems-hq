#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 STARTUP TARGET AUDIT ==="

echo
echo "=== 1) Listening processes on 3000 / 3001 / 3012 / 3013 / 3014 ==="
lsof -nP -iTCP:3000 -iTCP:3001 -iTCP:3012 -iTCP:3013 -iTCP:3014 -sTCP:LISTEN || true

echo
echo "=== 2) package.json scripts ==="
python3 - << 'PY'
import json
from pathlib import Path
data = json.loads(Path("package.json").read_text())
scripts = data.get("scripts", {})
if not scripts:
    print("(no package scripts defined)")
else:
    for key, value in sorted(scripts.items()):
        print(f"{key}: {value}")
PY

echo
echo "=== 3) Candidate startup files (first 60 lines each) ==="
for f in server.ts scripts/server.cjs scripts/_local/dev-server.ts; do
  echo "--- $f ---"
  if [ -f "$f" ]; then
    sed -n '1,60p' "$f"
  else
    echo "(missing)"
  fi
  echo
done

echo "=== END PHASE 487 STARTUP TARGET AUDIT ==="

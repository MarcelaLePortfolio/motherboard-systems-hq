
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 WORKER CRASH INSPECTION AFTER ARTIFACT PATCH ====="

echo ""

echo "[1] Runtime status"

docker compose ps -a

echo ""

echo "[2] Worker logs"

docker compose logs --tail=200 worker

echo ""

echo "[3] Local worker syntax/import inspection"

node --check server/worker/phase26_task_worker.mjs || true

echo ""

echo "[4] Show local worker import/helper region"

python3 - << 'PY'

from pathlib import Path

p = Path("server/worker/phase26_task_worker.mjs")

lines = p.read_text(errors="ignore").splitlines()

for start, end in [(1, 80), (90, 165)]:

    print(f"\n--- lines {start}-{end} ---")

    for n in range(start, min(end, len(lines)) + 1):

        print(f"{n}: {lines[n-1]}")

PY

echo ""

echo "[5] Git status"

git status --short

echo ""

echo "===== PHASE 719 WORKER CRASH INSPECTION COMPLETE ====="


#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 task_events RESTORATION SOURCE AUDIT ==="

echo
echo "=== 1) Candidate backup / seed / schema files ==="
find db -maxdepth 2 -type f | sort | sed -n '1,120p'

echo
echo "=== 2) task_events schema file (first 120 lines) ==="
sed -n '1,120p' db/task_events.schema.ts || true

echo
echo "=== 3) Seed SQL files (first 160 lines each) ==="
find db/seeds -maxdepth 2 -type f \( -name '*.sql' -o -name '*.ts' \) | sort | while read -r f; do
  echo "--- $f ---"
  sed -n '1,160p' "$f" || true
  echo
done

echo
echo "=== 4) SQLite backup inspection ==="
python3 - << 'PY'
import sqlite3
from pathlib import Path

candidates = sorted(Path("db").glob("*.sqlite")) + sorted(Path("db").glob("*.db"))
seen = set()
for path in candidates:
    if path.name in seen:
        continue
    seen.add(path.name)
    print(f"--- {path} ---")
    try:
        size = path.stat().st_size
        print(f"size_bytes: {size}")
        conn = sqlite3.connect(str(path))
        cur = conn.cursor()
        tables = [row[0] for row in cur.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").fetchall()]
        print("tables:", tables[:30])
        has_task_events = "task_events" in tables
        print("task_events_present:", has_task_events)
        if has_task_events:
            try:
                count = cur.execute("SELECT COUNT(*) FROM task_events").fetchone()[0]
                print("task_events_count:", count)
            except Exception as e:
                print("task_events_count_error:", e)
        conn.close()
    except Exception as e:
        print("inspect_error:", e)
    print()
PY

echo
echo "=== 5) task_events CREATE references in repo (bounded) ==="
grep -RIn 'CREATE TABLE.*task_events\|create table.*task_events\|task_events' . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  | head -120 || true

echo
echo "=== END PHASE 487 task_events RESTORATION SOURCE AUDIT ==="

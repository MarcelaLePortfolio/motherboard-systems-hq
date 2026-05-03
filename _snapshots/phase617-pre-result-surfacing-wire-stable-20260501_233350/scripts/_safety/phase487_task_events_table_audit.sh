#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 task_events TABLE AUDIT ==="

DB_PATH="db/main.db"

echo
echo "=== 1) db/client.ts (first 80 lines) ==="
sed -n '1,80p' db/client.ts || true

echo
echo "=== 2) Database file existence ==="
if [ -f "$DB_PATH" ]; then
  echo "OK   $DB_PATH exists"
  ls -lh "$DB_PATH"
else
  echo "MISS $DB_PATH"
fi

echo
echo "=== 3) Nearby db files ==="
find db -maxdepth 2 -type f | sort | head -80 || true

echo
echo "=== 4) task_events schema references (bounded) ==="
grep -RIn 'task_events' . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  | head -80 || true

echo
echo "=== 5) SQLite table check ==="
if [ -f "$DB_PATH" ]; then
  python3 - << 'PY'
import sqlite3
db_path = "db/main.db"
conn = sqlite3.connect(db_path)
cur = conn.cursor()
tables = cur.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").fetchall()
print("tables:")
for (name,) in tables[:100]:
    print(f"  {name}")
exists = cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='task_events'").fetchone()
print()
print("task_events_present:", bool(exists))
conn.close()
PY
else
  echo "Skipping SQLite inspection because db/main.db is missing"
fi

echo
echo "=== END PHASE 487 task_events TABLE AUDIT ==="

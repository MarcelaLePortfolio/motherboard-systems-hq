#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 /tasks/recent FAILURE AUDIT ==="

echo
echo "=== 1) tasks route source (first 120 lines) ==="
sed -n '1,120p' routes/api/tasks.ts || true

echo
echo "=== 2) Live task_events table schema from restored db ==="
python3 - << 'PY'
import sqlite3
conn = sqlite3.connect("db/main.db")
cur = conn.cursor()

print("pragma_table_info(task_events):")
for row in cur.execute("PRAGMA table_info(task_events)"):
    print(row)

print()
print("sample rows:")
try:
    rows = cur.execute("SELECT * FROM task_events LIMIT 5").fetchall()
    for row in rows:
        print(row)
except Exception as e:
    print("sample_rows_error:", e)

conn.close()
PY

echo
echo "=== 3) reflection_index schema (for comparison) ==="
python3 - << 'PY'
import sqlite3
conn = sqlite3.connect("db/main.db")
cur = conn.cursor()

print("pragma_table_info(reflection_index):")
for row in cur.execute("PRAGMA table_info(reflection_index)"):
    print(row)

conn.close()
PY

echo
echo "=== 4) direct reproduction of tasks query against sqlite ==="
python3 - << 'PY'
import sqlite3
conn = sqlite3.connect("db/main.db")
cur = conn.cursor()
query = "SELECT id, type, agent, status, payload, result, created_at FROM task_events ORDER BY created_at DESC LIMIT 20"
print("query:", query)
try:
    rows = cur.execute(query).fetchall()
    print("row_count:", len(rows))
    for row in rows[:5]:
        print(row)
except Exception as e:
    print("query_error:", e)
conn.close()
PY

echo
echo "=== END PHASE 487 /tasks/recent FAILURE AUDIT ==="

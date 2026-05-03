#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 MAIN DB RESTORE + PROBE ==="

SOURCE_DB="db/main_backup_before_rebuild.sqlite"
TARGET_DB="db/main.db"
ZERO_BACKUP="db/main.db.zero_byte_backup_phase487"

echo
echo "=== Step 1: confirm audited source and target ==="
ls -lh "$SOURCE_DB" "$TARGET_DB"

echo
echo "=== Step 2: preserve current target snapshot ==="
cp "$TARGET_DB" "$ZERO_BACKUP"
ls -lh "$ZERO_BACKUP"

echo
echo "=== Step 3: restore target from audited backup source ==="
cp "$SOURCE_DB" "$TARGET_DB"
ls -lh "$TARGET_DB"

echo
echo "=== Step 4: verify restored tables ==="
python3 - << 'PY'
import sqlite3
db_path = "db/main.db"
conn = sqlite3.connect(db_path)
cur = conn.cursor()
tables = [row[0] for row in cur.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").fetchall()]
print("tables:", tables)
for name in ("task_events", "reflection_index"):
    exists = cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name=?", (name,)).fetchone()
    print(f"{name}_present:", bool(exists))
    if exists:
        count = cur.execute(f"SELECT COUNT(*) FROM {name}").fetchone()[0]
        print(f"{name}_count:", count)
conn.close()
PY

echo
echo "=== Step 5: rerun bounded server.ts live-start probe ==="
bash scripts/_safety/phase487_server_ts_live_start_probe.sh

echo
echo "=== Step 6: tail live-start probe output ==="
tail -80 docs/phase487_server_ts_live_start_probe_output.txt || true

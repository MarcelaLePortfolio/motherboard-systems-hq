
set -euo pipefail

DB_PATH="db/main.db"
BACKUP_DIR="backups"
BACKUP_FILE="$BACKUP_DIR/demo_backup_latest.db"
HASH_FILE="$BACKUP_FILE.md5"
if [[ ! -f "$DB_PATH" ]]; then
  echo "❌ SQLite database not found at $DB_PATH"
  exit 1
fi

mkdir -p "$BACKUP_DIR"
db_size_bytes=$(stat -f%z "$DB_PATH")
db_size_kb=$(( (db_size_bytes + 1023) / 1024 ))
required_kb=$(( db_size_kb * 2 + 10240 ))
available_kb=$(df -Pk "$BACKUP_DIR" | awk 'NR==2 {print $4}')

if (( available_kb < required_kb )); then
  echo "❌ Not enough disk space for safe backup. Required: ${required_kb}K, Available: ${available_kb}K"
  exit 1
fi

echo "💾 Creating single-rotation backup of $DB_PATH"
tmp_file="${BACKUP_FILE}.tmp"

sqlite3 "$DB_PATH" "PRAGMA wal_checkpoint(FULL);" >/dev/null

sqlite3 "$DB_PATH" ".backup '$tmp_file'"

integrity=$(sqlite3 "$tmp_file" "PRAGMA integrity_check;")
if [[ "$integrity" != "ok" ]]; then
  echo "❌ Backup integrity_check failed: $integrity"
  rm -f "$tmp_file"
  exit 1
fi
mv -f "$tmp_file" "$BACKUP_FILE"

if command -v md5 >/dev/null 2>&1; then
  md5 "$BACKUP_FILE" > "$HASH_FILE"
elif command -v md5sum >/dev/null 2>&1; then
  md5sum "$BACKUP_FILE" > "$HASH_FILE"
fi
sync "$BACKUP_FILE" || true
sync || true

chmod 640 "$BACKUP_FILE" || true

echo "✅ Backup completed successfully."
echo "   → File: $BACKUP_FILE"
[[ -f "$HASH_FILE" ]] && echo "   → Checksum: $HASH_FILE"

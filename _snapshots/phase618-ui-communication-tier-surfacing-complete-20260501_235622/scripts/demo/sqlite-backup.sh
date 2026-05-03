
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DB_PATH="$ROOT_DIR/db/main.db"
OUT_DIR="$ROOT_DIR/backups/sqlite"
STAMP="$(date +"%Y%m%d_%H%M%S")"
mkdir -p "$OUT_DIR"

if command -v sqlite3 >/dev/null 2>&1; then
  sqlite3 "$DB_PATH" ".backup '$OUT_DIR/demo_$STAMP.db'"
  echo "💾 SQLite backup created → $OUT_DIR/demo_$STAMP.db"
else
  cp -f "$DB_PATH" "$OUT_DIR/demo_$STAMP.raw.db"
  echo "⚠️ sqlite3 not found; raw file copy saved → $OUT_DIR/demo_$STAMP.raw.db"
fi

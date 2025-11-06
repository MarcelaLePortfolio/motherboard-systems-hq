
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DB_PATH="$ROOT_DIR/db/main.db"
SEED_SCRIPT="$ROOT_DIR/scripts/loaders/reflection-loader.ts"
TMP_DIR="$ROOT_DIR/public/tmp"

echo "🧽 Restoring demo baseline…"

pm2 stop reflection-sse-server 2>/dev/null || true
pm2 stop ops-sse-server 2>/dev/null || true

mkdir -p "$ROOT_DIR/backups/sqlite"
STAMP="$(date +"%Y%m%d_%H%M%S")"
if command -v sqlite3 >/dev/null 2>&1; then
  sqlite3 "$DB_PATH" ".backup '$ROOT_DIR/backups/sqlite/demo_pre-restore_$STAMP.db'"
else
  echo "⚠️ sqlite3 not found; skipping .backup step."
fi

if command -v node >/dev/null 2>&1 && [ -f "$ROOT_DIR/drizzle/migrate.ts" ]; then
  pnpm tsx drizzle/migrate.ts
else
  echo "🗑️ Truncating known tables (fallback)…"
  node - <<'NODE'
const fs = require("fs");
const path = require("path");
const Database = require("better-sqlite3");
const root = path.join(__dirname, "..", "..");
const dbPath = path.join(root, "db", "main.db");
if (!fs.existsSync(dbPath)) process.exit(0);
const db = new Database(dbPath);
const tables = ["task_events","reflection_index","ops_events","agents_status"];
for (const t of tables) {
  try { db.prepare(`DELETE FROM ${t}`).run(); } catch {}
}
NODE
fi

if [ -f "$SEED_SCRIPT" ]; then
  echo "🌱 Reseeding reflections → public/tmp/reflections.json"
  pnpm tsx "$SEED_SCRIPT" || true
fi

mkdir -p "$TMP_DIR"
echo '{"status":"idle","sequence":[],"updated_at":'$(date +%s)'}' > "$TMP_DIR/atlas-status.json"

pm2 restart ops-sse-server 2>/dev/null || true
sleep 1
pm2 restart reflection-sse-server 2>/dev/null || true
sleep 1
pm2 save

echo "✅ Demo baseline restored."

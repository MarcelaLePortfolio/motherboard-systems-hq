set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DB_FILE="$ROOT_DIR/db/main.db"
SEED_SQL="$ROOT_DIR/db/seeds/phase4_demo_seed.sql"

echo "<0001f9f9> Resetting demo reflection data..."
sqlite3 "$DB_FILE" < "$SEED_SQL"
echo "✅ Demo reflections reseeded successfully."

echo "ℹ️ Verify with:"
echo "   sqlite3 db/main.db \"SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 5;\""

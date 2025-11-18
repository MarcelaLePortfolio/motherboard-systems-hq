
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "▶ Phase 9 checks starting…"

"$ROOT_DIR/scripts/ops/pm2-rehydrate-check.sh" reflection-sse-server || true

"$ROOT_DIR/scripts/ops/prewarm-agents.sh" || true

pnpm tsx "$ROOT_DIR/scripts/ops/run-create-atlas.ts"

echo "✅ Phase 9 checks completed."

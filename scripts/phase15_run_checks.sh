set -euo pipefail

echo "== Phase 15 – Quick Confidence Checks =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo
echo "→ Running Tasks Widget Smoke Check"
./scripts/phase15_tasks_widget_smoke.sh

echo
echo "✅ All Phase 15 checks passed."

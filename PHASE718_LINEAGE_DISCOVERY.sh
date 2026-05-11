
#!/bin/bash

set -euo pipefail

echo "===== PHASE 718 LINEAGE DISCOVERY ====="

echo ""

echo "[1] retry_of_task_id references"

grep -RIn "retry_of_task_id" public/js server app src 2>/dev/null || true

echo ""

echo "[2] execution_mode references"

grep -RIn "execution_mode" public/js server app src 2>/dev/null || true

echo ""

echo "[3] strategy references"

grep -RIn "strategy" public/js server app src 2>/dev/null || true

echo ""

echo "[4] SSE retry references"

grep -RInE "task\.created|task\.completed|task\.failed|fresh-context|standard_retry|rebuild_context" public/js server app src 2>/dev/null || true

echo ""

echo "[5] API tasks payload sample"

curl -fsS http://localhost:3000/api/tasks | python3 -m json.tool | head -120 || true

echo ""

echo "[6] Git state"

git status --short

git log --oneline --decorate -5

echo ""

echo "===== END PHASE 718 LINEAGE DISCOVERY ====="


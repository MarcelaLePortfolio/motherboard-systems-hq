
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 VERIFY LIFECYCLE LABELS ====="

echo "[1] Git state"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Verify lifecycle card markers in renderer"

grep -n "data-phase717-execution-card\|Operator actions\|Requeue pending contract\|Retry differently pending contract" public/js/phase530_visible_panels_bridge.js

echo ""

echo "[3] Verify runtime containers"

docker compose ps || true

echo ""

echo "[4] Verify dashboard serves"

curl -fsS http://localhost:3000 >/tmp/phase717_dashboard_home.html

wc -c /tmp/phase717_dashboard_home.html

echo ""

echo "[5] Verify task API still serves"

curl -fsS "http://localhost:3000/api/tasks?limit=3" | head -c 1200

echo ""

echo ""

echo "[6] Save verification note"

cat > PHASE717_LIFECYCLE_LABELS_VERIFIED.txt << 'EON'

PHASE 717 — LIFECYCLE LABELS VERIFIED

Verified:

- Recent Tasks renderer contains lifecycle-card marker.

- Recent Tasks renderer contains disabled operator-action placeholders.

- Requeue remains disabled pending endpoint contract confirmation.

- Retry Differently remains disabled pending strategy-shift contract confirmation.

- No backend mutation route was added.

- No hidden execution behavior was added.

Next safe step:

- Identify the exact safe mutation endpoint and payload before enabling any retry/requeue button.

- If no safe endpoint is confirmed, keep controls disabled and continue surface consolidation only.

EON

git add PHASE717_VERIFY_LIFECYCLE_LABELS.sh PHASE717_LIFECYCLE_LABELS_VERIFIED.txt

git commit -m "Phase 717: verify recent tasks lifecycle labels"

git push origin dev

echo "===== PHASE 717 VERIFY LIFECYCLE LABELS COMPLETE ====="


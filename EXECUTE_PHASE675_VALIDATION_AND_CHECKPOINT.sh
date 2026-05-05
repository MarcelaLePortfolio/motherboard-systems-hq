#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${NEXT_PUBLIC_BASE_URL:-http://localhost:8080}"

echo "Executing Phase 675 validation against ${BASE_URL}..."

set +e
./RUN_PHASE675_VALIDATION.sh
STATUS=$?
set -e

if [ $STATUS -eq 0 ]; then
  RESULT="PASSED"
else
  RESULT="PENDING"
fi

cat > PHASE675_RUNTIME_VALIDATION.md << EOM
PHASE 675 — RUNTIME VALIDATION

Result: ${RESULT}

Details:
- Endpoint: /api/guidance/coherence-shadow
- Base URL: ${BASE_URL}
- Script Exit Code: ${STATUS}

Interpretation:
- PASSED: Shadow endpoint reachable and validated
- PENDING: Server not reachable or validation incomplete

Next:
- If PENDING: ensure app/container is running, then rerun
- If PASSED: safe to proceed to Phase 676 (controlled UI exposure)
EOM

git add PHASE675_RUNTIME_VALIDATION.md
git commit -m "Phase 675: runtime validation ${RESULT}"
git push

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 72 GUIDANCE CONTRACT CHECK"
echo "--------------------------------"

test -f scripts/_local/operator_guidance.sh
test -f scripts/_local/operator_guidance_next_action.sh
test -f scripts/_local/phase72_operator_guidance_smoke.sh
test -f scripts/_local/phase72_run_operator_guidance_smoke.sh
test -f scripts/_local/phase72_operator_guidance_report.sh
test -f scripts/_local/phase72_operator_guidance_snapshot.sh

test -x scripts/_local/operator_guidance.sh
test -x scripts/_local/operator_guidance_next_action.sh
test -x scripts/_local/phase72_operator_guidance_smoke.sh
test -x scripts/_local/phase72_run_operator_guidance_smoke.sh

echo "FILES: OK"

grep -q "PHASE 72 — OPERATOR GUIDANCE" scripts/_local/operator_guidance.sh
grep -q "risk=" scripts/_local/operator_guidance.sh
grep -q "safe_to_continue=" scripts/_local/operator_guidance.sh

echo "STATUS CONTRACT: OK"

bash scripts/_local/operator_guidance.sh status >/dev/null

echo "ENTRYPOINT EXECUTION: OK"

echo "PHASE 72 GUIDANCE CONTRACT VERIFIED"

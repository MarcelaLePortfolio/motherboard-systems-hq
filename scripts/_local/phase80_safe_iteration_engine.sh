#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 80 — SAFE ITERATION ENGINE"
echo "--------------------------------"
echo "generated_at=$(date +"%Y-%m-%d %H:%M:%S")"
echo "repo=$(basename "$ROOT_DIR")"
echo "branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
echo "commit=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

echo ""
echo "ENGINE STEP 1 — START COMMAND"
bash scripts/_local/phase76_operator_start_command.sh

echo ""
echo "ENGINE STEP 2 — DAILY LOOP"
bash scripts/_local/phase77_operator_daily_loop.sh

echo ""
echo "ENGINE STEP 3 — RISK SURFACE"
bash scripts/_local/phase78_operator_risk_surface.sh

echo ""
echo "ENGINE STEP 4 — CHANGE IMPACT PREVIEW"
bash scripts/_local/phase79_change_impact_preview.sh

echo ""
echo "ENGINE STEP 5 — PREFLIGHT SMOKE"
bash scripts/_local/phase75_operator_preflight_smoke.sh

echo ""
echo "ENGINE STEP 6 — START COMMAND SMOKE"
bash scripts/_local/phase76_operator_start_command_smoke.sh

echo ""
echo "ENGINE STEP 7 — DAILY LOOP SMOKE"
bash scripts/_local/phase77_operator_daily_loop_smoke.sh

echo ""
echo "ENGINE STEP 8 — RISK SURFACE SMOKE"
bash scripts/_local/phase78_operator_risk_surface_smoke.sh

echo ""
echo "ENGINE STEP 9 — CHANGE IMPACT SMOKE"
bash scripts/_local/phase79_change_impact_preview_smoke.sh

echo ""
echo "SAFE ITERATION ENGINE RESULT: READY FOR CONTROLLED DEVELOPMENT"

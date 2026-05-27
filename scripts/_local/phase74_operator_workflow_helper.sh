#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 74 — OPERATOR WORKFLOW HELPER"
echo "-----------------------------------"

echo "STEP 1 — SAFETY GATE"
if ! bash scripts/_local/phase73_run_safety_gate.sh; then
  echo "WORKFLOW STOPPED — SAFETY GATE FAILED"
  exit 1
fi

echo ""
echo "STEP 2 — GUIDANCE STATUS"
bash scripts/_local/operator_guidance.sh status

echo ""
echo "STEP 3 — GUIDANCE SMOKE"
bash scripts/_local/phase72_run_operator_guidance_smoke.sh

echo ""
echo "STEP 4 — PROTECTION GATE"
bash scripts/_local/phase65_pre_commit_protection_gate.sh

echo ""
echo "STEP 5 — DASHBOARD HEALTH"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep dashboard || true

echo ""
echo "WORKFLOW RESULT: SAFE DEVELOPMENT STATE VERIFIED"

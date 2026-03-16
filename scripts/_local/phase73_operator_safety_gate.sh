#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 73 — OPERATOR SAFETY GATE"
echo "--------------------------------"

GUIDANCE="$(bash scripts/_local/operator_guidance.sh status)"

RISK="$(echo "$GUIDANCE" | awk -F= '/^risk=/{print $2}')"
SAFE="$(echo "$GUIDANCE" | awk -F= '/^safe_to_continue=/{print $2}')"

echo "risk=$RISK"
echo "safe_to_continue=$SAFE"

if [[ "$RISK" == "HIGH" ]]; then
  echo "SAFETY GATE: BLOCK"
  echo "Reason: protection gate failing"
  exit 2
fi

if [[ "$SAFE" == "INVESTIGATE" ]]; then
  echo "SAFETY GATE: CAUTION"
  echo "Reason: runtime health unclear"
  exit 1
fi

echo "SAFETY GATE: PASS"

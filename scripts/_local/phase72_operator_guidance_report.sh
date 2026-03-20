#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="artifacts/operator-guidance"
mkdir -p "$OUT_DIR"

TS="$(date +"%Y%m%d_%H%M%S")"
OUT_FILE="$OUT_DIR/phase72_operator_guidance_report_${TS}.txt"

{
  echo "PHASE 72 — OPERATOR GUIDANCE REPORT"
  echo "Generated: $(date)"
  echo "Repository: $(basename "$ROOT_DIR")"
  echo "Commit: $(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
  echo

  echo "SYSTEM STATE"
  if docker ps --format '{{.Names}}' | grep -qx dashboard; then
    echo "dashboard=healthy"
  else
    echo "dashboard=missing"
  fi

  echo
  echo "PROTECTION GATE"
  if bash scripts/_local/phase65_pre_commit_protection_gate.sh >/tmp/phase72_protection_gate.log 2>&1; then
    echo "protection_gate=pass"
  else
    echo "protection_gate=fail"
  fi

  echo
  echo "TELEMETRY HEALTH"
  if curl -sf http://localhost:3000/api/health >/tmp/phase72_api_health.json 2>/dev/null; then
    echo "api_health=responding"
  else
    echo "api_health=not_responding"
  fi

  echo
  echo "RISK CLASSIFICATION"
  DASHBOARD_OK=0
  GATE_OK=0
  API_OK=0

  if docker ps --format '{{.Names}}' | grep -qx dashboard; then
    DASHBOARD_OK=1
  fi

  if bash scripts/_local/phase65_pre_commit_protection_gate.sh >/dev/null 2>&1; then
    GATE_OK=1
  fi

  if curl -sf http://localhost:3000/api/health >/dev/null 2>&1; then
    API_OK=1
  fi

  if [[ "$DASHBOARD_OK" -eq 1 && "$GATE_OK" -eq 1 && "$API_OK" -eq 1 ]]; then
    echo "risk=LOW"
    echo "safe_to_continue=YES"
    echo "recommended_next_action=Continue Phase 72 guidance refinement"
  elif [[ "$GATE_OK" -eq 0 ]]; then
    echo "risk=HIGH"
    echo "safe_to_continue=NO"
    echo "recommended_next_action=Stop and restore golden anchor before further modification"
  else
    echo "risk=MEDIUM"
    echo "safe_to_continue=INVESTIGATE"
    echo "recommended_next_action=Verify runtime health before continuing"
  fi

  echo
  echo "ARTIFACT"
  echo "report_path=$OUT_FILE"
} | tee "$OUT_FILE"

echo
echo "Saved report to: $OUT_FILE"

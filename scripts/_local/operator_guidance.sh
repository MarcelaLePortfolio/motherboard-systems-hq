#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

MODE="${1:-status}"

OUT_DIR="artifacts/operator-guidance"
mkdir -p "$OUT_DIR"

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

dashboard_ok() {
  docker ps --format '{{.Names}}' | grep -qx dashboard
}

gate_ok() {
  bash scripts/_local/phase65_pre_commit_protection_gate.sh >/dev/null 2>&1
}

api_ok() {
  curl -sf http://localhost:3000/api/health >/dev/null 2>&1
}

classify_risk() {
  if dashboard_ok && gate_ok && api_ok; then
    echo "LOW"
  elif ! gate_ok; then
    echo "HIGH"
  else
    echo "MEDIUM"
  fi
}

safe_to_continue() {
  local risk
  risk="$(classify_risk)"
  case "$risk" in
    LOW) echo "YES" ;;
    HIGH) echo "NO" ;;
    *) echo "INVESTIGATE" ;;
  esac
}

recommended_next_action() {
  local risk
  risk="$(classify_risk)"
  case "$risk" in
    LOW) echo "Continue Phase 72 guidance refinement" ;;
    HIGH) echo "Stop and restore golden anchor before further modification" ;;
    *) echo "Verify runtime health before continuing" ;;
  esac
}

system_state() {
  if dashboard_ok; then
    echo "HEALTHY"
  else
    echo "DEGRADED"
  fi
}

print_status() {
  echo "PHASE 72 — OPERATOR GUIDANCE"
  echo "generated_at=$(timestamp)"
  echo "system_state=$(system_state)"
  echo "risk=$(classify_risk)"
  echo "recommended_next_action=$(recommended_next_action)"
  echo "safe_to_continue=$(safe_to_continue)"
}

write_report() {
  local ts out_file
  ts="$(date +"%Y%m%d_%H%M%S")"
  out_file="$OUT_DIR/operator_guidance_${ts}.txt"

  {
    print_status
    echo "dashboard_container=$(dashboard_ok && echo present || echo missing)"
    echo "protection_gate=$(gate_ok && echo pass || echo fail)"
    echo "api_health=$(api_ok && echo responding || echo not_responding)"
    echo "git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
  } | tee "$out_file"

  echo "report_path=$out_file"
}

case "$MODE" in
  status)
    print_status
    ;;
  report)
    write_report
    ;;
  *)
    echo "usage: $0 [status|report]" >&2
    exit 1
    ;;
esac

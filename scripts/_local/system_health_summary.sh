#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

LATEST_FILE=$(ls -t docs/system_health_check_*.txt 2>/dev/null | head -n 1 || true)

if [ -z "${LATEST_FILE}" ]; then
  echo "No system health check file found."
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/system_health_summary_${STAMP}.txt"

{
  echo "SYSTEM HEALTH SUMMARY"
  echo "source_file=${LATEST_FILE}"
  echo

  echo "=== REBOOT DETECTION ==="
  grep -i "last reboot\|system boot" "${LATEST_FILE}" || echo "No reboot line found"
  echo

  echo "=== CPU / MEMORY SIGNAL ==="
  grep -i "cpu\|physmem\|mem\|load" "${LATEST_FILE}" || echo "No CPU/memory signals found"
  echo

  echo "=== DOCKER STATUS ==="
  grep -i "docker" "${LATEST_FILE}" || echo "Docker not detected"
  echo

  echo "=== PORT BINDINGS ==="
  grep -i ":3000\|:8080\|:5432" "${LATEST_FILE}" || echo "No monitored ports active"
  echo

  echo "=== PM2 STATUS ==="
  grep -i "pm2" "${LATEST_FILE}" || echo "PM2 not detected"
  echo

  echo "=== ERROR SIGNALS ==="
  grep -i "panic\|error\|fail" "${LATEST_FILE}" || echo "No critical errors detected"
  echo

  echo "=== CLOUDFARE STATUS ==="
  grep -i "cloudflared" "${LATEST_FILE}" || echo "No tunnels running"
  echo

  echo "=== AGENT LOG SIGNAL ==="
  grep -i "matilda\|cade\|effie" "${LATEST_FILE}" || echo "No agent log output detected"
  echo

  echo "=== SUMMARY INTERPRETATION ==="
  echo "If reboot detected + no panic logs → likely OS-level restart (not code-induced)"
  echo "If Docker/PM2 missing → services did not auto-recover"
  echo "If ports missing → dashboard/backend not running"
  echo "If errors present → inspect logs above"
  echo

} > "${OUT}"

echo "${OUT}"

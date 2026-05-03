#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

LATEST=$(ls -t docs/system_health_deep_check_*.txt 2>/dev/null | head -n 1 || true)

if [ -z "$LATEST" ]; then
  echo "No deep check file found"
  exit 1
fi

echo "INTERPRETING: $LATEST"
echo

echo "=== BOOT TIME ==="
grep -i "sec =\|usec =" "$LATEST" || echo "Boot time not found"
echo

echo "=== SHUTDOWN CAUSE ==="
grep -i "Previous shutdown cause" "$LATEST" || echo "No shutdown cause found"
echo

echo "=== PANIC CHECK ==="
grep -i "panic" "$LATEST" || echo "No panic indicators"
echo

echo "=== UPTIME ==="
grep -i "load averages" "$LATEST" || echo "No uptime line found"
echo

echo "=== MEMORY PRESSURE SUMMARY ==="
grep -i "System-wide memory free percentage" "$LATEST" || echo "No memory pressure issues detected"
echo

echo "=== FINAL HEALTH READ ==="
echo "- If NO panic + reboot detected → likely OS-level restart (safe)"
echo "- If shutdown cause present → decode next"
echo "- If memory normal → not RAM crash"
echo "- If no thermal logs → not overheating"
echo

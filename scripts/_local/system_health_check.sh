#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/system_health_check_${STAMP}.txt"

{
  echo "SYSTEM HEALTH CHECK"
  echo "timestamp=${STAMP}"
  echo

  echo "=== SYSTEM UPTIME ==="
  uptime
  echo

  echo "=== LAST REBOOT ==="
  who -b || true
  echo

  echo "=== CPU + MEMORY ==="
  top -l 1 | head -n 20
  echo

  echo "=== DISK USAGE ==="
  df -h
  echo

  echo "=== DOCKER STATUS ==="
  docker ps || echo "Docker not running"
  echo

  echo "=== PORT CHECK (3000 / 8080 / 5432) ==="
  lsof -i :3000 || true
  lsof -i :8080 || true
  lsof -i :5432 || true
  echo

  echo "=== PM2 STATUS ==="
  pm2 list || echo "PM2 not running"
  echo

  echo "=== RECENT SYSTEM LOGS (last 50 lines) ==="
  log show --predicate 'eventMessage contains "panic" || eventMessage contains "error"' --last 1h | tail -n 50 || true
  echo

  echo "=== CLOUDFARE TUNNEL PROCESSES ==="
  ps aux | grep cloudflared | grep -v grep || true
  echo

  echo "=== AGENT LOG TAIL (if exists) ==="
  [ -f ~/matilda.log ] && tail -n 20 ~/matilda.log || true
  [ -f ~/cade.log ] && tail -n 20 ~/cade.log || true
  [ -f ~/effie.log ] && tail -n 20 ~/effie.log || true
  echo

} > "${OUT}"

echo "${OUT}"

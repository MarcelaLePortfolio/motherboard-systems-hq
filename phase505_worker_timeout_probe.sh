#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase505_worker_timeout_probe.txt"
mkdir -p docs

{
  echo "PHASE 505 — Worker + Dashboard Timeout Probe"
  echo "Timestamp: $(date)"
  echo

  echo "Docker compose ps"
  docker compose ps
  echo

  echo "Dashboard health"
  curl -sS --max-time 5 http://localhost:8080/api/health || true
  echo
  echo

  echo "Chat direct probe"
  curl -sS --max-time 20 \
    -H "Content-Type: application/json" \
    -X POST http://localhost:8080/api/chat \
    -d '{"agent":"matilda","message":"Quick systems check from dashboard."}' || true
  echo
  echo

  echo "Worker logs"
  docker logs --tail 120 motherboard_systems_hq-worker-1 2>&1 || true
  echo

  echo "Dashboard logs"
  docker logs --tail 120 motherboard_systems_hq-dashboard-1 2>&1 || true
} > "$OUT"

cat "$OUT"

#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase501_chat_timeout_probe.txt"
mkdir -p docs

{
  echo "PHASE 501 — Chat Timeout Probe"
  echo "Timestamp: $(date)"
  echo

  echo "Git status"
  git status --short
  echo

  echo "Docker containers"
  docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
  echo

  echo "API health"
  curl -sS --max-time 5 http://localhost:8080/api/health || true
  echo
  echo

  echo "Chat endpoint direct probe"
  curl -sS --max-time 20 \
    -H "Content-Type: application/json" \
    -X POST http://localhost:8080/api/chat \
    -d '{"agent":"matilda","message":"Quick systems check from dashboard."}' || true
  echo
  echo

  echo "Recent server logs"
  docker logs --tail 120 motherboard-systems-hq-app-1 2>&1 || true
} > "$OUT"

cat "$OUT"

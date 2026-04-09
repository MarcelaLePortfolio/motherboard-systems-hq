#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_operator_guidance_minimal_probe.txt"

{
  echo "PHASE 456 — OPERATOR GUIDANCE MINIMAL PROBE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== OPS STREAM (FIRST 20 LINES) ==="
  timeout 3 curl -NsS "http://localhost:8080/events/ops" | head -20 || true
  echo

  echo "=== REFLECTIONS STREAM (FIRST 20 LINES) ==="
  timeout 3 curl -NsS "http://localhost:8080/events/reflections" | head -20 || true
  echo

  echo "=== DASHBOARD LOGS (LAST 40) ==="
  docker compose logs --tail 40 dashboard 2>&1 || true
  echo
} | tee "$OUT"

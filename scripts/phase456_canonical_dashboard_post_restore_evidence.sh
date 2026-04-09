#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_canonical_dashboard_post_restore_evidence.txt"

{
  echo "PHASE 456 — CANONICAL DASHBOARD POST-RESTORE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== PRECHECK ==="
  df -h .
  echo
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  echo
  git status --short || true
  echo

  echo "=== CANONICAL COMPOSE STATE ==="
  docker compose ps || true
  echo

  echo "=== ACTIVE PORT OWNERS ==="
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  lsof -nP -iTCP:5432 -sTCP:LISTEN || true
  echo

  echo "=== HTTP CHECKS ==="
  curl -I --max-time 10 http://localhost:8080 || true
  curl -I --max-time 10 http://localhost:8080/dashboard.html || true
  echo

  echo "=== CANONICAL DASHBOARD LOGS (TAIL 200) ==="
  docker compose logs --tail 200 dashboard 2>&1 || true
  echo

  echo "=== CANONICAL POSTGRES LOGS (TAIL 120) ==="
  docker compose logs --tail 120 postgres 2>&1 || true
  echo

  echo "=== HEALTH / GUIDANCE / SSE ASSET TARGETS ==="
  grep -RniE "SYSTEM_HEALTH|operatorGuidance|events/ops|events/reflections|phase457_neutralize_legacy_observational_consumers|phase457_restore_task_panels|HIGH" \
    public server src app routes . 2>/dev/null | head -500 || true
  echo

  echo "=== DASHBOARD HTML / JS ASSET REFERENCES ==="
  curl -s http://localhost:8080/dashboard.html | grep -nE "operatorGuidance|events/ops|events/reflections|phase457|bundle|dashboard" || true
  echo

  echo "=== API PROBES ==="
  curl -s --max-time 10 http://localhost:8080/api/tasks?limit=5 || true
  echo
  curl -s --max-time 10 http://localhost:8080/api/runs?limit=5 || true
  echo
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,320p' "$OUT"

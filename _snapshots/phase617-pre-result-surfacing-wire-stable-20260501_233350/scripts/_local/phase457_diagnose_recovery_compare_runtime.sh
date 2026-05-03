#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/21_recovery_compare_runtime_diagnosis.txt"

{
  echo "PHASE 457 - RECOVERY COMPARE RUNTIME DIAGNOSIS"
  echo "=============================================="
  echo
  echo "PURPOSE"
  echo "Diagnose why the three recovery comparison URLs are not showing anything."
  echo
  echo "EXPECTED URLS"
  echo "phase65_layout    -> http://localhost:8081"
  echo "phase65_wiring    -> http://localhost:8082"
  echo "operator_guidance -> http://localhost:8083"
  echo
  echo "=== DOCKER CONTAINER STATE ==="
  docker ps -a || true
  echo
  echo "=== DOCKER COMPOSE PROJECTS (best effort via names) ==="
  docker ps -a --format '{{.Names}}' | grep -E 'mbhq_phase65_layout|mbhq_phase65_wiring|mbhq_operator_guidance|dashboard|postgres' || true
  echo
  echo "=== PORT LISTEN CHECK ==="
  lsof -nP -iTCP:8081 -sTCP:LISTEN || true
  lsof -nP -iTCP:8082 -sTCP:LISTEN || true
  lsof -nP -iTCP:8083 -sTCP:LISTEN || true
  echo
  echo "=== HTTP CHECKS ==="
  curl -I --max-time 5 http://localhost:8081 || true
  curl -I --max-time 5 http://localhost:8082 || true
  curl -I --max-time 5 http://localhost:8083 || true
  echo
  echo "=== SAVED LAUNCH LOGS ==="
  for f in \
    docs/recovery_full_audit/phase65_layout_launch_port_8081.txt \
    docs/recovery_full_audit/phase65_wiring_launch_port_8082.txt \
    docs/recovery_full_audit/operator_guidance_launch_port_8083.txt
  do
    echo
    echo "----- $f -----"
    [ -f "$f" ] && tail -n 80 "$f" || echo "MISSING_LOG"
  done
  echo
  echo "=== VISUAL BOOT LOGS ==="
  for f in \
    docs/recovery_full_audit/phase65_layout_visual_boot.txt \
    docs/recovery_full_audit/phase65_wiring_visual_boot.txt \
    docs/recovery_full_audit/operator_guidance_visual_boot.txt
  do
    echo
    echo "----- $f -----"
    [ -f "$f" ] && tail -n 80 "$f" || echo "MISSING_LOG"
  done
  echo
  echo "DETERMINISTIC INTERPRETATION"
  echo "If nothing is listening on 8081/8082/8083, the comparison launch did not actually start usable servers."
  echo "That means the recovery candidates may still be fine, but the launch step failed."
} > "$OUT"

echo "WROTE=$OUT"
sed -n '1,260p' "$OUT"

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/27_failed_relaunch_root_cause.txt"

{
  echo "PHASE 457 - FAILED RELAUNCH ROOT CAUSE INSPECTION"
  echo "================================================="
  echo
  echo "PURPOSE"
  echo "Inspect why 8081/8082/8083 are still dark after the relaunch attempt."
  echo

  for pair in \
    "phase65_layout|8081|mbhq_phase65_layout|../mbhq_recovery_visual_compare/phase65_layout" \
    "phase65_wiring|8082|mbhq_phase65_wiring|../mbhq_recovery_visual_compare/phase65_wiring" \
    "operator_guidance|8083|mbhq_operator_guidance|../mbhq_recovery_visual_compare/operator_guidance"
  do
    NAME="${pair%%|*}"
    REST="${pair#*|}"
    PORT="${REST%%|*}"
    REST="${REST#*|}"
    PROJECT="${REST%%|*}"
    WT_PATH="${REST#*|}"

    echo "===== ${NAME} ====="
    echo "WORKTREE=${WT_PATH}"
    echo "PROJECT=${PROJECT}"
    echo "URL=http://localhost:${PORT}"
    echo

    echo "[worktree exists]"
    if [ -d "$WT_PATH" ]; then
      echo "YES"
    else
      echo "NO"
      echo
      continue
    fi
    echo

    echo "[docker compose files]"
    ls -1 "$WT_PATH"/docker-compose*.yml 2>/dev/null || true
    echo

    echo "[compose config]"
    (
      cd "$WT_PATH"
      docker compose -f docker-compose.yml config 2>&1 || true
    )
    echo

    echo "[compose override contents]"
    (
      cd "$WT_PATH"
      for f in docker-compose.override.yml docker-compose.phase457.override.yml docker-compose.phase457.port.override.yml
      do
        if [ -f "$f" ]; then
          echo "--- $f ---"
          sed -n '1,200p' "$f"
          echo
        fi
      done
    )
    echo

    echo "[project containers]"
    docker ps -a --filter "name=${PROJECT}" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' || true
    echo

    echo "[all candidate-related containers]"
    docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -E "${PROJECT}|phase65_layout|phase65_wiring|operator_guidance" || true
    echo

    echo "[dashboard logs]"
    docker logs "$(docker ps -aq --filter "name=${PROJECT}-dashboard-1" | head -n 1)" 2>&1 | tail -n 120 || true
    echo

    echo "[postgres logs]"
    docker logs "$(docker ps -aq --filter "name=${PROJECT}-postgres-1" | head -n 1)" 2>&1 | tail -n 120 || true
    echo

    echo "[launch artifact tail]"
    for f in \
      "docs/recovery_full_audit/${NAME}_phase457_launch.txt" \
      "docs/recovery_full_audit/${NAME}_relaunch_port_${PORT}.txt" \
      "docs/recovery_full_audit/${NAME}_force_relaunch_port_${PORT}.txt"
    do
      if [ -f "$ROOT/$f" ]; then
        echo "--- $f ---"
        tail -n 80 "$ROOT/$f"
        echo
      fi
    done

    echo "[port listen]"
    lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN || true
    echo

    echo "[http head]"
    curl -I --max-time 10 "http://localhost:${PORT}" 2>&1 || true
    echo
  done

  echo "DETERMINISTIC NEXT STEP"
  echo "Use the first concrete failure in this report as the only next mutation target."
} > "$OUT"

sed -n '1,320p' "$OUT"

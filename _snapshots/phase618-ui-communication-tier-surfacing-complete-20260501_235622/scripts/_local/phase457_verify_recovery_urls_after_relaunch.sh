#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/26_post_relaunch_live_check.txt"

{
  echo "PHASE 457 - POST RELAUNCH LIVE CHECK"
  echo "===================================="
  echo
  for pair in \
    "phase65_layout|8081" \
    "phase65_wiring|8082" \
    "operator_guidance|8083"
  do
    NAME="${pair%%|*}"
    PORT="${pair##*|}"

    echo "===== ${NAME} ====="
    echo "URL=http://localhost:${PORT}"
    echo

    echo "[port listen]"
    lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN || true
    echo

    echo "[http headers]"
    curl -I --max-time 10 "http://localhost:${PORT}" || true
    echo

    echo "[title]"
    curl -L --max-time 10 "http://localhost:${PORT}" 2>/dev/null | grep -o '<title>[^<]*</title>' | head -n 1 || true
    echo

    echo "[body markers]"
    BODY="$(curl -L --max-time 10 "http://localhost:${PORT}" 2>/dev/null || true)"
    printf "%s\n" "$BODY" | grep -Eo 'Operator Console|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Agent Pool|Guidance|Atlas Subsystem Status' | sort -u || true
    echo
  done

  echo "DETERMINISTIC INTERPRETATION"
  echo "- If 8081/8082/8083 respond, the comparison stack is finally live."
  echo "- If one or more still fail, inspect:"
  echo "  docs/recovery_full_audit/phase65_layout_phase457_launch.txt"
  echo "  docs/recovery_full_audit/phase65_wiring_phase457_launch.txt"
  echo "  docs/recovery_full_audit/operator_guidance_phase457_launch.txt"
} > "$OUT"

sed -n '1,240p' "$OUT"

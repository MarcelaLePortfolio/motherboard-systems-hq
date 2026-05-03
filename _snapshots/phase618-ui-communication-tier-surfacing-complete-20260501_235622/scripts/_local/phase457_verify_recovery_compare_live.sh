#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

OUT="docs/recovery_full_audit/23_recovery_compare_live_verification.txt"

URLS=(
  "phase65_layout|8081|mbhq_phase65_layout|recovery/phase65_layout"
  "phase65_wiring|8082|mbhq_phase65_wiring|recovery/phase65_wiring"
  "operator_guidance|8083|mbhq_operator_guidance|recovery/operator_guidance"
)

{
  echo "PHASE 457 - RECOVERY COMPARE LIVE VERIFICATION"
  echo "=============================================="
  echo

  for item in "${URLS[@]}"; do
    NAME="${item%%|*}"
    REST="${item#*|}"
    PORT="${REST%%|*}"
    REST="${REST#*|}"
    PROJECT="${REST%%|*}"
    BRANCH="${REST##*|}"

    echo "===== $NAME ====="
    echo "URL=http://localhost:${PORT}"
    echo

    echo "[port listen]"
    lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN || true
    echo

    echo "[http headers]"
    curl -I --max-time 10 "http://localhost:${PORT}" || true
    echo

    echo "[dashboard markers]"
    BODY="$(curl -L --max-time 10 "http://localhost:${PORT}" 2>/dev/null || true)"
    printf "%s\n" "$BODY" | grep -o '<title>[^<]*</title>' | head -n 1 || true
    printf "%s\n" "$BODY" | grep -Eo 'Operator|Dashboard|Tasks|Guidance|Agent' | sort -u || true
    echo

    echo "[compose status]"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f "../mbhq_recovery_visual_compare/${NAME}/docker-compose.yml" \
      -f "../mbhq_recovery_visual_compare/${NAME}/docker-compose.phase457.override.yml" \
      ps || true
    echo

    echo "[dashboard logs]"
    COMPOSE_PROJECT_NAME="$PROJECT" docker compose \
      -f "../mbhq_recovery_visual_compare/${NAME}/docker-compose.yml" \
      -f "../mbhq_recovery_visual_compare/${NAME}/docker-compose.phase457.override.yml" \
      logs dashboard --tail=40 || true
    echo
  done

} > "$OUT"

echo "WROTE=$OUT"
sed -n '1,200p' "$OUT"

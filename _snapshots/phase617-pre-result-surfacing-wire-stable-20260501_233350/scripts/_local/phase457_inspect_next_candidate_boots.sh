#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
mkdir -p "$ROOT/docs/recovery_full_audit"
OUT="$ROOT/docs/recovery_full_audit/29_next_candidate_boot_inspection.txt"

inspect_candidate() {
  local name="$1"
  local worktree="$2"
  local port="$3"

  echo "===== ${name} ====="
  echo "WORKTREE=${worktree}"
  echo "URL=http://localhost:${port}"
  echo

  if [ ! -d "$worktree" ]; then
    echo "STATUS=MISSING_WORKTREE"
    echo
    return 0
  fi

  cd "$worktree"

  echo "[git branch]"
  git branch --show-current || true
  echo

  echo "[compose files]"
  ls -1 docker-compose*.yml 2>/dev/null || true
  echo

  echo "[compose ps -a]"
  docker compose ps -a || true
  echo

  echo "[dashboard logs]"
  docker compose logs dashboard --tail=120 || true
  echo

  echo "[postgres logs]"
  docker compose logs postgres --tail=80 || true
  echo

  echo "[port listen]"
  lsof -nP -iTCP:"${port}" -sTCP:LISTEN || true
  echo

  echo "[http headers]"
  curl -I --max-time 10 "http://localhost:${port}" || true
  echo

  echo "[title]"
  curl -L --max-time 10 "http://localhost:${port}" 2>/dev/null | grep -o '<title>[^<]*</title>' | head -n 1 || true
  echo

  echo "[body markers]"
  BODY="$(curl -L --max-time 10 "http://localhost:${port}" 2>/dev/null || true)"
  printf "%s\n" "$BODY" | grep -Eo 'Operator Console|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Agent Pool|Guidance|Atlas Subsystem Status' | sort -u || true
  echo

  cd "$ROOT"
}

{
  echo "PHASE 457 - NEXT CANDIDATE BOOT INSPECTION"
  echo "=========================================="
  echo
  inspect_candidate "phase65_wiring" "../mbhq_recovery_visual_compare/phase65_wiring" "8092"
  inspect_candidate "operator_guidance" "../mbhq_recovery_visual_compare/operator_guidance" "8093"
  echo "DETERMINISTIC INTERPRETATION"
  echo "- If 8092 or 8093 still fail, use the first concrete dashboard log error as the only next mutation target."
  echo "- If one responds, that candidate is ready for visual comparison."
} > "$OUT"

sed -n '1,260p' "$OUT"

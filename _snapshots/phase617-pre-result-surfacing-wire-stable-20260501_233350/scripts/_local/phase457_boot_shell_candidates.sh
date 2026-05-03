#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/35_shell_candidate_boot_matrix.txt"
mkdir -p docs/recovery_full_audit

CANDIDATES=$(grep -E '^[0-9a-f]{8} \|' docs/recovery_full_audit/34_visual_shell_candidate_shortlist.txt | awk '{print $1}' | head -n 5)

PORT=8100

{
echo "PHASE 457 — SHELL CANDIDATE BOOT MATRIX"
echo "======================================="
echo

for SHA in $CANDIDATES
do
  PORT=$((PORT+1))

  WT="../mbhq_recovery_visual_compare/shell_${SHA}"

  echo "===== $SHA → $WT → $PORT ====="

  rm -rf "$WT" || true

  git worktree add "$WT" "$SHA"

  cd "$WT"

  docker compose down -v || true

  sed -i.bak "s/published: \"[0-9]*\"/published: \"$PORT\"/g" docker-compose.yml 2>/dev/null || true

  docker compose up -d --build postgres || true

  sleep 5

  docker compose up -d --build dashboard || true

  sleep 6

  echo "--- title ---"
  curl -s "http://localhost:$PORT" | grep -o '<title>[^<]*</title>' || true

  echo "--- markers ---"
  curl -s "http://localhost:$PORT" | \
  grep -Eo 'Operator Console|Guidance|Workspace|Atlas|Task Delegation|Agent Pool|Matilda Chat Console' | \
  sort -u || true

  echo "--- url ---"
  echo "http://localhost:$PORT"

  cd "$ROOT"

  echo

done

} > "$OUT"

sed -n '1,200p' "$OUT"


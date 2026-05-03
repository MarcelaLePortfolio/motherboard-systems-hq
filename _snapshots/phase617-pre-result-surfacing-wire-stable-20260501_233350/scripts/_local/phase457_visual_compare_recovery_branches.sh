#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

WT_BASE="../mbhq_recovery_visual_compare"
mkdir -p "$WT_BASE"

declare -a PAIRS=(
  "recovery/phase65_layout:phase65_layout"
  "recovery/phase65_wiring:phase65_wiring"
  "recovery/operator_guidance:operator_guidance"
)

for pair in "${PAIRS[@]}"; do
  BRANCH="${pair%%:*}"
  NAME="${pair##*:}"
  WT_PATH="$WT_BASE/$NAME"

  if [ -d "$WT_PATH/.git" ] || git worktree list | grep -Fq " $WT_PATH"; then
    echo "WORKTREE_EXISTS=$WT_PATH"
  else
    git worktree add "$WT_PATH" "$BRANCH"
  fi

  (
    cd "$WT_PATH"
    docker compose up --build -d dashboard
    sleep 5
    docker compose ps
    docker compose logs dashboard --tail=40
  ) > "$ROOT/docs/recovery_full_audit/${NAME}_visual_boot.txt" 2>&1 || true
done

{
  echo "PHASE 457 - VISUAL COMPARE WORKTREES"
  echo "===================================="
  echo
  echo "PURPOSE"
  echo "Prepare isolated visual inspection worktrees for the three recovery candidates."
  echo
  for pair in "${PAIRS[@]}"; do
    BRANCH="${pair%%:*}"
    NAME="${pair##*:}"
    WT_PATH="$WT_BASE/$NAME"
    echo "BRANCH=$BRANCH"
    echo "WORKTREE=$WT_PATH"
    echo "BOOT_LOG=docs/recovery_full_audit/${NAME}_visual_boot.txt"
    echo
  done
  echo "NEXT"
  echo "Open each worktree dashboard manually and compare layout/wiring."
  echo "Suggested order:"
  echo "1. recovery/phase65_layout"
  echo "2. recovery/phase65_wiring"
  echo "3. recovery/operator_guidance"
} > docs/recovery_full_audit/17_visual_compare_worktrees.txt

echo "DONE"

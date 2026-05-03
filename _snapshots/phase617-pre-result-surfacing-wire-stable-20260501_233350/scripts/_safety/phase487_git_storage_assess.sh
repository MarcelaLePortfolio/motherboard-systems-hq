#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SUMMARY_PATH="$REPO_ROOT/docs/phase487_git_storage_assessment.md"
TMP_PACK_LIST="/tmp/motherboard-systems-hq-artifacts/phase487_git_pack_sizes.txt"

cd "$REPO_ROOT"
mkdir -p /tmp/motherboard-systems-hq-artifacts

find .git/objects/pack -type f -print0 2>/dev/null \
  | xargs -0 stat -f '%z %N' 2>/dev/null \
  | sort -nr \
  | head -10 \
  | awk '{size=$1; $1=""; sub(/^ /,""); printf "%12d bytes  %s\n", size, $0}' > "$TMP_PACK_LIST" || true

{
  echo "# Phase 487 — Git Storage Assessment"
  echo
  echo "## Disk status"
  df -h .
  echo
  echo "## .git size"
  du -sh .git
  echo
  echo "## git count-objects -vH"
  git count-objects -vH
  echo
  echo "## Largest pack files"
  cat "$TMP_PACK_LIST"
} > "$SUMMARY_PATH"

echo "Wrote $SUMMARY_PATH"

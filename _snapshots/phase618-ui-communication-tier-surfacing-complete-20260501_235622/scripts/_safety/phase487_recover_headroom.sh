#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "=== DISK STATUS ==="
df -h .

echo
echo "=== TOP 20 REPO PATHS AFTER RECOVERY ==="
du -sh ./* ./.??* 2>/dev/null | sort -hr | head -20 || true

echo
echo "=== TOP 20 DOC FILES AFTER RECOVERY ==="
find docs -type f -print0 2>/dev/null \
  | xargs -0 stat -f '%z %N' 2>/dev/null \
  | sort -nr \
  | head -20 \
  | awk '{size=$1; $1=""; sub(/^ /,""); printf "%12d bytes  %s\n", size, $0}' || true

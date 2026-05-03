#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "=== DISK STATUS ==="
df -h .

echo
echo "=== TOP 15 REPO PATHS ==="
du -sh ./* ./.??* 2>/dev/null | sort -hr | head -15 || true

echo
echo "=== TOP 15 DOC FILES ==="
find docs -type f -print0 2>/dev/null \
  | xargs -0 stat -f '%z %N' 2>/dev/null \
  | sort -nr \
  | head -15 \
  | awk '{size=$1; $1=""; sub(/^ /,""); printf "%12d bytes  %s\n", size, $0}' || true
